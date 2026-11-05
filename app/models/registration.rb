# app/models/registration.rb

class Registration < ApplicationRecord
  KIT_SIZES = %w[P M G GG XGG].freeze

  belongs_to :athlete
  belongs_to :event
  belongs_to :distance
  belongs_to :category
  belongs_to :lot

  has_one  :payment,          dependent: :destroy
  has_many :athlete_checkins, dependent: :destroy
  has_many :timings,          dependent: :destroy
  has_one  :result,           dependent: :destroy
  has_many :transfers

  has_one_attached :atestado_file

  # ── Atributo virtual — usado apenas em transferências ──────────────
  attr_accessor :transferencia

  # ── Enums ──────────────────────────────────────────────────────────
  enum :status, {
    pendente:    "pending",
    confirmado:  "confirmed",
    checado:     "checked_in",
    cancelado:   "cancelled",
    transferido: "transferred"
  }, default: :pendente

  # ── Callbacks ──────────────────────────────────────────────────────
  before_validation :set_data_inscricao,          on: :create
  before_validation :generate_qr_code_hash,       on: :create
  before_validation :normalize_tamanho_kit
  before_validation :normalize_contato_emergencia
  before_validation :normalize_fone_emergencia

  # ── Validações ─────────────────────────────────────────────────────
  validates :status,
            presence:  true,
            inclusion: { in: statuses.keys }

  validates :tamanho_kit,
            presence:  true,
            inclusion: {
              in:      KIT_SIZES,
              message: "deve ser um dos tamanhos: #{KIT_SIZES.join(', ')}"
            }

  # contato e fone são dispensados em inscrições criadas por transferência
  validates :contato_emergencia,
            presence: true,
            unless:   :transferencia?

  validates :fone_emergencia,
            presence: true,
            format: {
              with:    /\A\d{10,11}\z/,
              message: "deve conter 10 ou 11 dígitos, incluindo o DDD"
            },
            unless: :transferencia?

  validates :numero_dorsal,
            uniqueness: { scope: :event_id },
            allow_nil:  true

  validates :aceite_lgpd, acceptance: true

  # ── Regras de negócio ──────────────────────────────────────────────
  validate :category_belongs_to_event
  validate :category_belongs_to_distance
  validate :lot_belongs_to_event
  validate :lot_belongs_to_category_distance
  validate :athlete_is_eligible_for_category

  # ── Escopos ────────────────────────────────────────────────────────
  scope :ativos_para_prova, -> { where(status: %i[confirmado checado]) }

  private

  def transferencia?
    transferencia == true
  end

  def set_data_inscricao
    self.data_inscricao ||= Time.current
  end

  def generate_qr_code_hash
    self.qr_code_hash ||= SecureRandom.hex(12)
  end

  def normalize_tamanho_kit
    self.tamanho_kit = tamanho_kit.to_s.strip.upcase.presence
  end

  def normalize_contato_emergencia
    self.contato_emergencia = contato_emergencia.to_s.strip.presence
  end

  def normalize_fone_emergencia
    self.fone_emergencia = fone_emergencia.to_s.gsub(/\D/, "").presence
  end

  def category_belongs_to_distance
    return unless category.present? && distance.present?
    unless category.distance_id == distance_id
      errors.add(:category_id, "não pertence à distância selecionada")
    end
  end

  def athlete_is_eligible_for_category
    return unless athlete.present? && category.present? &&
                  event.present? && event.data_largada.present?
    category.erros_de_elegibilidade(
      athlete,
      reference_date: event.data_largada.to_date
    ).each { |e| errors.add(:base, e) }
  end

  def category_belongs_to_event
    return unless category.present? && event.present?
    unless category.distance&.event_id == event_id
      errors.add(:category_id, "não pertence ao evento selecionado")
    end
  end

  def lot_belongs_to_event
    return unless lot.present? && event.present?
    unless lot.distance&.event_id == event_id
      errors.add(:lot_id, "não pertence ao evento selecionado")
    end
  end

  def lot_belongs_to_category_distance
    return unless lot.present? && category.present?
    unless lot.distance_id == category.distance_id
      errors.add(:lot_id, "não pertence à distância selecionada")
    end
  end
end