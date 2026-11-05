class Transfer < ApplicationRecord
  # ── Associações ────────────────────────────────────────────────

  belongs_to :registration

  belongs_to :athlete_origem,
             class_name: "Athlete",
             foreign_key: :athlete_origem_id

  belongs_to :athlete_destino,
             class_name: "Athlete",
             foreign_key: :athlete_destino_id,
             optional: true

  has_one :pending_transfer,
          dependent: :destroy

  # ── Constantes ─────────────────────────────────────────────────

  STATUSES = %w[
    pendente
    concluido
    cancelado
    expirado
  ].freeze

  TOKEN_EXPIRY = 48.hours

  # ── Validações ─────────────────────────────────────────────────

  validates :status,
            presence: true,
            inclusion: {
              in: STATUSES
            }

  validates :taxa,
            numericality: {
              greater_than_or_equal_to: 0
            }

  validates :solicitada_em,
            presence: true

  validates :email_destino,
            presence: true,
            format: {
              with: URI::MailTo::EMAIL_REGEXP
            }

  validates :token,
            presence: true,
            uniqueness: true

  # ── Callbacks ──────────────────────────────────────────────────

  before_validation :set_defaults,
                    on: :create

  before_validation :generate_token,
                    on: :create

  before_validation :set_token_expiration,
                    on: :create

  # ── Escopos ─────────────────────────────────────────────────────

  scope :pendentes,
        -> { where(status: "pendente") }

  scope :concluidas,
        -> { where(status: "concluido") }

  scope :expiradas,
        -> { where(status: "expirado") }

  scope :recentes,
        -> { order(created_at: :desc) }

  # ── Métodos de estado ───────────────────────────────────────────

  def pendente?
    status == "pendente"
  end

  def concluida?
    status == "concluido"
  end

  def expirada?
    status == "expirado"
  end

  def token_expirado?
    token_expira_em.present? &&
      token_expira_em < Time.current
  end

  # ── Geração de token ────────────────────────────────────────────

  def self.gerar_token
    loop do
      token = SecureRandom.urlsafe_base64(32)

      break token unless exists?(token: token)
    end
  end

  private

  # ── Defaults ────────────────────────────────────────────────────

  def set_defaults
    self.status ||= "pendente"

    self.taxa ||= 0

    self.solicitada_em ||= Time.current
  end

  # ── Token ───────────────────────────────────────────────────────

  def generate_token
    self.token ||= self.class.gerar_token
  end

  def set_token_expiration
    self.token_expira_em ||= TOKEN_EXPIRY.from_now
  end
end