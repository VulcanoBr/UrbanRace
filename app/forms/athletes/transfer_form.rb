# app/forms/athletes/transfer_form.rb

class Athletes::TransferForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :cpf_destino, :string
  attribute :email_destino, :string
  attribute :registration_id, :integer
  attribute :athlete_origem_id, :integer

  validates :cpf_destino, presence: true

  validates :email_destino,
            presence: true,
            format: {
              with: URI::MailTo::EMAIL_REGEXP,
              message: "inválido"
            }

  validates :registration_id, presence: true
  validates :athlete_origem_id, presence: true

  validate :cpf_destino_formato_valido
  validate :registration_pertence_ao_atleta
  validate :inscricao_elegivel
  validate :destino_diferente_da_origem
  validate :destino_sem_inscricao_no_evento
  validate :email_corresponde_ao_cpf
  validate :destinatario_elegivel_na_categoria

  def save
    return false unless valid?

    if atleta_destino_por_cpf.present?
      Athletes::TransferRegistrationService.executar_imediato(
        registration: registration,
        atleta_destino: atleta_destino_por_cpf,
        atleta_origem_id: athlete_origem_id
      )
    else
      Athletes::TransferRegistrationService.executar_com_convite(
        registration: registration,
        email_destino: email_destino.downcase.strip,
        cpf_destino: cpf_destino_normalizado,
        atleta_origem_id: athlete_origem_id
      )
    end

    true

  rescue Athletes::TransferRegistrationService::TransferError => e
    errors.add(:base, e.message)
    false
  end

  def destinatario_ja_cadastrado?
    atleta_destino_por_cpf.present?
  end

  def registration
    @registration ||= Registration
      .includes(
        :event,
        :distance,
        :category,
        :athlete_checkins,
        :payment
      )
      .find_by(id: registration_id)
  end

  private

  def destinatario_elegivel_na_categoria
    return unless atleta_destino_por_cpf.present?
    return unless registration.present?
    return unless registration.category.present?

    erros = registration.category.erros_de_elegibilidade(
      atleta_destino_por_cpf,
      reference_date: registration.event.data_largada.to_date
    )

    erros.each do |erro|
      errors.add(:cpf_destino, erro)
    end
  end

  # ============================================================
  # CPF
  # ============================================================

  def cpf_destino_normalizado
    cpf_destino.to_s.gsub(/\D/, "")
  end

  def cpf_destino_formato_valido
    return if cpf_destino.blank?

    unless cpf_destino_normalizado.length == 11
      errors.add(:cpf_destino, "deve ter 11 dígitos")
    end
  end

  # ============================================================
  # DESTINATÁRIO
  # ============================================================

  def atleta_destino_por_cpf
    return if cpf_destino_normalizado.blank?

    @atleta_destino_por_cpf ||= Athlete.find_by(
      cpf: cpf_destino_normalizado
    )
  end

  def email_corresponde_ao_cpf
    return unless atleta_destino_por_cpf.present?
    return if email_destino.blank?

    if atleta_destino_por_cpf.email_address.downcase !=
       email_destino.downcase.strip

      errors.add(
        :email_destino,
        "não corresponde ao CPF informado"
      )
    end
  end

  # ============================================================
  # ORIGEM
  # ============================================================

  def registration_pertence_ao_atleta
    return if registration_id.blank?
    return if athlete_origem_id.blank?

    unless registration&.athlete_id == athlete_origem_id
      errors.add(
        :base,
        "Inscrição não encontrada."
      )
    end
  end

  def destino_diferente_da_origem
    return if cpf_destino.blank?
    return if athlete_origem_id.blank?

    origem = Athlete.find_by(id: athlete_origem_id)

    return unless origem

    if origem.cpf.to_s.gsub(/\D/, "") ==
       cpf_destino_normalizado

      errors.add(
        :cpf_destino,
        "não pode ser o seu próprio CPF."
      )
    end
  end

  # ============================================================
  # ELEGIBILIDADE DA INSCRIÇÃO
  # ============================================================

  def inscricao_elegivel
    return unless registration.present?

    unless registration.confirmado?
      errors.add(
        :base,
        "Apenas inscrições confirmadas (pagas) podem ser transferidas."
      )
      return
    end

    if registration.event.finished? ||
       registration.event.cancelled?

      errors.add(
        :base,
        "Não é possível transferir inscrição de evento finalizado ou cancelado."
      )
    end

    if registration.athlete_checkins.exists?
      errors.add(
        :base,
        "Você já realizou check-in neste evento. Transferência impossível."
      )
    end

    if registration.transferido?
      errors.add(
        :base,
        "Esta inscrição já foi transferida anteriormente."
      )
    end

    if Transfer
         .joins(:pending_transfer)
         .where(
           registration: registration,
           status: "pendente"
         )
         .where(
           "pending_transfers.expira_em > ?",
           Time.current
         )
         .exists?

      errors.add(
        :base,
        "Já existe um convite de transferência ativo. Aguarde expirar ou ser aceito."
      )
    end
  end

  # ============================================================
  # REGRA PRINCIPAL
  # DESTINATÁRIO NÃO PODE TER INSCRIÇÃO NO EVENTO
  # ============================================================

  def destino_sem_inscricao_no_evento
    return unless atleta_destino_por_cpf.present?
    return unless registration.present?

    ja_inscrito = Registration
      .where(
        athlete_id: atleta_destino_por_cpf.id,
        event_id: registration.event_id
      )
      .where.not(
        status: %w[
          cancelled
          transferred
        ]
      )
      .exists?

    if ja_inscrito
      errors.add(
        :cpf_destino,
        "já possui uma inscrição neste evento. A transferência não pode ser realizada."
      )
    end
  end
end