class Organizer::RegistrationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id,                  :integer
  attribute :athlete_id,          :integer
  attribute :event_id,            :integer
  attribute :distance_id,         :integer
  attribute :category_id,         :integer
  attribute :lot_id,              :integer
  attribute :status,              :string, default: "confirmado"
  attribute :tamanho_kit,         :string
  attribute :numero_dorsal,       :integer
  attribute :contato_emergencia,  :string
  attribute :fone_emergencia,     :string
  attribute :aceite_lgpd,         :boolean, default: true

  # Valores selecionados a preservar nos Turbo Streams
  attribute :selected_athlete_id,  :integer
  attribute :selected_distance_id, :integer

  attr_reader :registration

  validates :athlete_id, :event_id, :distance_id, :category_id,
            :lot_id, :tamanho_kit, :contato_emergencia, :fone_emergencia,
            presence: true
  validates :tamanho_kit,
            inclusion: { in: Registration::KIT_SIZES }
  validates :status,
            presence: true,
            inclusion: { in: Registration.statuses.keys }

  validate :phone_valido
  validate :distance_belongs_to_event
  validate :category_belongs_to_distance
  validate :lot_belongs_to_distance

  # ── Helpers para os selects ──────────────────────────────────────────────

  def event
    @event ||= Event.find_by(id: event_id) if event_id.present?
  end

  def distance
    @distance ||= Distance.find_by(id: distance_id) if distance_id.present?
  end

  def distances_options
    event&.distances&.ordered || []
  end

  def athletes_options
    return Athlete.order(:nome) if event_id.blank?

    inscritos_ids = Registration
                      .where(event_id: event_id)
                      .where.not(status: %w[cancelado cancelled])
                      .where.not(id: id.presence)   # exclui a própria inscrição no edit
                      .pluck(:athlete_id)

    Athlete.where.not(id: inscritos_ids).order(:nome)
  end

  def categories_options
    if distance_id.present?
      Category.where(distance_id: distance_id).ordered
    elsif event_id.present?
      Category.joins(:distance)
              .where(distances: { event_id: event_id })
              .ordered
    else
      []
    end
  end

  def lots_options
    if distance_id.present?
      Lot.where(distance_id: distance_id).ordered
    elsif event_id.present?
      Lot.joins(:distance)
         .where(distances: { event_id: event_id })
         .ordered
    else
      []
    end
  end

  # ── Persistência ─────────────────────────────────────────────────────────

  def persisted?
    id.present?
  end

  def self.from_model(reg)
    new(
      id:                 reg.id,
      athlete_id:         reg.athlete_id,
      event_id:           reg.event_id,
      distance_id:        reg.distance_id,
      category_id:        reg.category_id,
      lot_id:             reg.lot_id,
      status:             reg.status,
      tamanho_kit:        reg.tamanho_kit,
      numero_dorsal:      reg.numero_dorsal,
      contato_emergencia: reg.contato_emergencia,
      fone_emergencia:    reg.fone_emergencia
    )
  end

  def save
    return false unless valid?

    Registration.transaction do
     
      registration = id.present? ? Registration.find(id) : Registration.new

      if registration.new_record?
        registration.qr_code_hash  = SecureRandom.hex(10)
        registration.data_inscricao = Time.current
      end

      registration.assign_attributes(
        athlete_id:         athlete_id,
        event_id:           event_id,
        distance_id:        distance_id,
        category_id:        category_id,
        lot_id:             lot_id,
        status:             status,
        tamanho_kit:        tamanho_kit,
        numero_dorsal:      numero_dorsal,
        contato_emergencia: contato_emergencia,
        fone_emergencia:    fone_emergencia,
        aceite_lgpd:        aceite_lgpd
      )

      if registration.save
        self.id = registration.id
        if registration.new_record?
          RegistrationMailer.confirmation(registration).deliver_later
        end
        @registration = registration
        true
      else
        promote_errors(registration.errors)
        raise ActiveRecord::Rollback
      end
    end
  rescue StandardError => e
    errors.add(:base, "Erro ao processar inscrição: #{e.message}")
    false
  end

  private

  def distance_belongs_to_event
    return if distance_id.blank? || event_id.blank?
    unless Distance.exists?(id: distance_id, event_id: event_id)
      errors.add(:distance_id, "não pertence ao evento selecionado")
    end
  end

  def category_belongs_to_distance
    return if category_id.blank? || distance_id.blank?
    unless Category.exists?(id: category_id, distance_id: distance_id)
      errors.add(:category_id, "não pertence à distância selecionada")
    end
  end

  def lot_belongs_to_distance
    return if lot_id.blank? || distance_id.blank?
    unless Lot.exists?(id: lot_id, distance_id: distance_id)
      errors.add(:lot_id, "não pertence à distância selecionada")
    end
  end

  def phone_valido
    return if fone_emergencia.blank?
    limpo = fone_emergencia.gsub(/\D/, "")
    unless limpo.length.in?([10, 11])
      errors.add(:fone_emergencia,
        "inválido. Deve conter 10 dígitos (fixo) ou 11 dígitos (celular) com DDD")
    end
  end

  def promote_errors(model_errors)
    model_errors.each { |e| errors.add(e.attribute, e.message) }
  end
end