class Public::RegistrationForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Validations::Callbacks 

  attribute :nome,               :string
  attribute :email_address,      :string
  attribute :cpf,                :string
  attribute :nascimento,         :date
  attribute :sexo,               :string
  attribute :telefone,           :string
  attribute :password,           :string

  attribute :event_id,           :integer
  attribute :distance_id,        :integer
  attribute :category_id,        :integer
  attribute :lot_id,             :integer

  attribute :tamanho_kit,        :string
  attribute :contato_emergencia, :string
  attribute :fone_emergencia,    :string
  attribute :aceite_lgpd,       :boolean
  attribute :join_waitlist,      :boolean, default: false

  attr_accessor :atestado_file

  attr_reader :registration, :waitlist_entry

  MAX_ATESTADO_SIZE = 5.megabytes

  ATESTADO_CONTENT_TYPES = {
    ".pdf"  => "application/pdf",
    ".jpg"  => "image/jpeg",
    ".jpeg" => "image/jpeg",
    ".png"  => "image/png"
  }.freeze


  before_validation :normalize_cpf

  validates :nome,
          :email_address,
          :cpf,
          :nascimento,
          :sexo,
          :distance_id,
          :category_id,
          :lot_id,
          :tamanho_kit,
          :contato_emergencia,
          :fone_emergencia,
          presence: true

  validates :email_address,
            format: {
              with: URI::MailTo::EMAIL_REGEXP
            }

  validates :cpf,
          presence: true,
          cpf: true

  validates :aceite_lgpd,
            acceptance: true

  validates :tamanho_kit,
          inclusion: {
            in: Registration::KIT_SIZES
          }

  #validate :distance_belongs_to_event
  validate :category_belongs_to_distance
  validate :lot_belongs_to_distance
  validate :category_belongs_to_event
  validate :nascimento_valido
  validate :athlete_must_be_eligible_for_category
  validate :nascimento_nao_pode_ser_futura
  validate :fone_emergencia_valido
  validate :atestado_medico_valido

  def save(current_athlete = nil)
    return false unless valid?

    ActiveRecord::Base.transaction do

      distance = Distance.lock.find_by(id: distance_id)
      category = Category.find_by(id: category_id)
      lot      = Lot.lock.find_by(id: lot_id)
      event    = Event.find_by(id: event_id)

      unless event
        errors.add(:base, "Evento não encontrado.")
        raise ActiveRecord::Rollback
      end

      unless distance
        errors.add(:base, "Distância não encontrada.")
        raise ActiveRecord::Rollback
      end

      unless category
        errors.add(:base, "Categoria não encontrada.")
        raise ActiveRecord::Rollback
      end

      unless lot
        errors.add(:base, "Lote não encontrado.")
        raise ActiveRecord::Rollback
      end

      # -------------------------------------------------------------
      # Segurança: categoria pertence à distância
      # -------------------------------------------------------------
      unless category.distance_id == distance.id
        errors.add(
          :category_id,
          "não pertence à distância selecionada."
        )
        raise ActiveRecord::Rollback
      end

      # -------------------------------------------------------------
      # Segurança: distância pertence ao evento
      # -------------------------------------------------------------
      unless distance.event_id == event.id
        errors.add(
          :distance_id,
          "não pertence ao evento selecionado."
        )
        raise ActiveRecord::Rollback
      end

      # -------------------------------------------------------------
      # Segurança: lote pertence à distância
      # -------------------------------------------------------------
      unless lot.distance_id == distance.id
        errors.add(
          :lot_id,
          "não pertence à distância selecionada."
        )
        raise ActiveRecord::Rollback
      end

      # -------------------------------------------------------------
      # Agora sim cria/localiza o atleta definitivamente
      # -------------------------------------------------------------
      athlete =
        current_athlete || find_or_create_athlete

      return false if errors.any?

      # -------------------------------------------------------------
      # Elegibilidade SEXO + IDADE
      # -------------------------------------------------------------
      athlete_for_validation = current_athlete || build_athlete_for_validation

      unless athlete_for_validation
        raise ActiveRecord::Rollback
      end

      erros_elegibilidade =
        category.erros_de_elegibilidade(
          athlete_for_validation,
          reference_date: event.data_largada.to_date
        )

      if erros_elegibilidade.any?
        erros_elegibilidade.each do |mensagem|
          errors.add(:base, mensagem)
        end

        raise ActiveRecord::Rollback
      end

      # -------------------------------------------------------------
      # Lote ativo
      # -------------------------------------------------------------
      unless lot.ativo?
        errors.add(
          :base,
          "O lote de inscrições expirou. Reinicie o processo."
        )
        raise ActiveRecord::Rollback
      end

      # -------------------------------------------------------------
      # Vagas
      # -------------------------------------------------------------
      lote_esgotado =
        lot.vagas_disponiveis <= 0

      distancia_esgotada =
        distance.vagas_disponiveis <= 0

      if lote_esgotado || distancia_esgotada
        if join_waitlist

          @waitlist_entry =
            Public::WaitlistService.add_athlete(
              athlete: athlete,
              category: category,
              lot: lot
            )

          unless @waitlist_entry.persisted?
            errors.add(
              :base,
              "Não foi possível entrar na lista de espera."
            )

            raise ActiveRecord::Rollback
          end

          return :waitlist
        else
          errors.add(
            :base,
            lote_esgotado ?
              "vagas_lote_esgotadas" :
              "vagas_distancia_esgotadas"
          )

          raise ActiveRecord::Rollback
        end
      end

      # -------------------------------------------------------------
      # Criação da inscrição
      # -------------------------------------------------------------
      registration = Registration.new(
        athlete: athlete,
        event_id: event.id,
        distance_id: distance.id,
        category_id: category.id,
        lot: lot,
        status: "pending",
        tamanho_kit: tamanho_kit,
        contato_emergencia: contato_emergencia,
        fone_emergencia: fone_emergencia,
        data_inscricao: Time.current,
        qr_code_hash: SecureRandom.hex(12),
        aceite_lgpd: true,
        kit_entregue: false
      )

      if atestado_file.present?
        registration.atestado_file.attach(atestado_file)
        registration.atestado_enviado = true
      end

      if registration.save
        @registration = registration

        waitlist_entry = Waitlist.find_by(
          athlete_id: athlete.id,
          distance_id: distance.id,
          status: "notificado"
        )

        waitlist_entry&.update_columns(
          status: "convertido"
        )

        true
      else
        promote_errors(registration.errors)
        raise ActiveRecord::Rollback
      end
    end

  rescue StandardError => e
    Rails.logger.error(
      "Public::RegistrationForm#save: #{e.class}: #{e.message}"
    )
    Rails.logger.error(e.backtrace.first(10).join("\n"))

    errors.add(
      :base,
      "Erro no processamento: #{e.message}"
    )

    false
  end

  def vagas_esgotadas?
    errors.full_messages.any? { |m|
      m.include?("vagas_lote_esgotadas") || m.include?("vagas_distancia_esgotadas")
    }
  end

  def validar_elegibilidade_do_atleta(athlete, category)
    return if athlete.blank?
    return if category.blank?

    data_prova = category.distance.event.data_largada&.to_date

    unless data_prova
      errors.add(
        :base,
        "A data da prova não está definida."
      )
      return
    end

    erros = category.erros_de_elegibilidade(
      athlete,
      reference_date: data_prova
    )

    erros.each do |erro|
      errors.add(:base, erro)
    end
  end

  def event
    @event ||= Event.find_by(id: event_id)
  end

  def distance
    @distance ||= Distance.find_by(id: distance_id)
  end

  def category
    @category ||= Category.find_by(id: category_id)
  end

  def lot
    @lot ||= Lot.find_by(id: lot_id)
  end

  private

  def atestado_medico_valido
    return if atestado_file.blank?

    unless atestado_file.respond_to?(:size) &&
          atestado_file.respond_to?(:tempfile) &&
          atestado_file.respond_to?(:original_filename)
      errors.add(:atestado_file, "não é um arquivo válido.")
      return
    end

    if atestado_file.size > MAX_ATESTADO_SIZE
      errors.add(:atestado_file, "deve ter no máximo 5 MB.")
    end

    extension = File.extname(atestado_file.original_filename).downcase
    expected_content_type = ATESTADO_CONTENT_TYPES[extension]

    unless expected_content_type
      errors.add(
        :atestado_file,
        "deve estar no formato PDF, JPG, JPEG ou PNG."
      )
      return
    end

    tempfile = atestado_file.tempfile
    tempfile.rewind

    detected_content_type = Marcel::MimeType.for(tempfile)

    tempfile.rewind

    unless detected_content_type == expected_content_type
      errors.add(
        :atestado_file,
        "não corresponde ao formato do arquivo informado."
      )
    end
  rescue StandardError => e
    Rails.logger.warn(
      "[RegistrationForm] Falha ao validar atestado: #{e.class}: #{e.message}"
    )

    errors.add(
      :atestado_file,
      "não pôde ser validado. Selecione o arquivo novamente."
    )
  ensure
    tempfile&.rewind if defined?(tempfile) && tempfile
  end

  def normalize_cpf
    self.cpf = cpf.to_s.gsub(/\D/, "")
  end

  def fone_emergencia_valido
    return if fone_emergencia.blank?

    telefone = fone_emergencia.gsub(/\D/, "")

    unless telefone.match?(/\A\d{10,11}\z/)
      errors.add(
        :fone_emergencia,
        "deve conter 10 ou 11 dígitos, incluindo o DDD"
      )
    end
  end

  def distance_belongs_to_event
    return if distance_id.blank? || event_id.blank?

    unless distance&.event_id == event_id
      errors.add(
        :distance_id,
        "não pertence ao evento selecionado."
      )
    end
  end

  def nascimento_nao_pode_ser_futura
    return if nascimento.blank?

    if nascimento > Date.current
      errors.add(
        :nascimento,
        "não pode ser uma data futura."
      )
    end
  end

  def build_athlete_for_validation
    Athlete.new(
      nome: nome,
      cpf: cpf.to_s.gsub(/\D/, ""),
      nascimento: nascimento,
      sexo: normalizar_sexo(sexo),
      telefone: telefone.to_s.gsub(/\D/, ""),
      email_address: email_address.to_s.downcase.strip
    )
  end

  def category_belongs_to_distance
    return if category.blank? || distance.blank?

    unless category.distance_id == distance.id
      errors.add(
        :category_id,
        "não pertence à distância selecionada"
      )
    end
  end

  def lot_belongs_to_distance
    return if lot.blank? || distance.blank?

    unless lot.distance_id == distance.id
      errors.add(
        :lot_id,
        "não pertence à distância selecionada"
      )
    end
  end

  def category_belongs_to_event
    return if category.blank? || distance.blank? || event.blank?

    unless category.distance_id == distance.id &&
          distance.event_id == event.id
      errors.add(
        :category_id,
        "não pertence ao evento/distância selecionados"
      )
    end
  end

  def nascimento_valido
    return if nascimento.blank?
    return unless event&.data_largada.present?

    if nascimento > event.data_largada.to_date
      errors.add(
        :nascimento,
        "não pode ser posterior à data da prova."
      )
    end
  end

  def athlete_must_be_eligible_for_category
    return if category.blank?
    return if nascimento.blank?
    return if sexo.blank?
    return if event.blank?

    idade = calcular_idade(
      nascimento,
      event.data_largada.to_date
    )

    if idade < category.idade_min ||
      idade > category.idade_max

      errors.add(
        :nascimento,
        "idade incompatível com a categoria. " \
        "A categoria permite #{category.idade_min} a #{category.idade_max} anos. " \
        "A idade do atleta é #{idade} anos."
      )
    end

    unless %w[unissex geral].include?(category.sexo.to_s)
      if sexo.to_s != category.sexo.to_s
        errors.add(
          :sexo,
          "sexo incompatível com a categoria. " \
          "A categoria é #{category.sexo} e o sexo informado é #{sexo}."
        )
      end
    end
  end

  def calcular_idade(data_nascimento, data_referencia)
    data_referencia.year -
      data_nascimento.year -
      (
        data_referencia.month < data_nascimento.month ||
        (
          data_referencia.month == data_nascimento.month &&
          data_referencia.day < data_nascimento.day
        ) ? 1 : 0
      )
  end

  def normalizar_sexo(valor)
    case valor.to_s.strip.downcase
    when "m", "masculino"
      "masculino"
    when "f", "feminino"
      "feminino"
    when "unissex"
      "unissex"
    when "geral"
      "geral"
    else
      valor.to_s.strip.downcase
    end
  end

  def atleta_nao_pode_ter_inscricao_no_evento
    return unless registration.present?
  end

  def find_or_create_athlete
    normalized_email =
      email_address.to_s.downcase.strip

    normalized_cpf =
      cpf.to_s.gsub(/\D/, "")

    athlete_by_email =
      Athlete.find_by(
        email_address: normalized_email
      )

    athlete_by_cpf =
      Athlete.find_by(
        cpf: normalized_cpf
      )

    if athlete_by_email && athlete_by_cpf &&
      athlete_by_email.id != athlete_by_cpf.id

      errors.add(
        :base,
        "O e-mail e o CPF informados pertencem a atletas diferentes."
      )

      return nil
    end

    athlete =
      athlete_by_email ||
      athlete_by_cpf ||
      Athlete.new

    if athlete.new_record?
      athlete.assign_attributes(
        nome: nome,
        email_address: normalized_email,
        cpf: normalized_cpf,
        nascimento: nascimento,
        sexo: normalizar_sexo(sexo),
        telefone: telefone.to_s.gsub(/\D/, ""),
        password: password.presence || SecureRandom.hex(8)
      )

      unless athlete.save
        promote_errors(athlete.errors)
        return nil
      end
    end

    athlete
  end

  def promote_errors(model_errors)
    model_errors.each { |e| errors.add(e.attribute, e.message) }
  end
end