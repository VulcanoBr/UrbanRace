class PendingTransfer < ApplicationRecord
  STATUSES = %w[
    aguardando
    aceito
    expirado
    cancelado
  ].freeze

  belongs_to :transfer

  belongs_to :registration

  belongs_to :athlete_destino,
             class_name: "Athlete",
             optional: true

  validates :email_destino,
            presence: true,
            format: {
              with: URI::MailTo::EMAIL_REGEXP
            }

  validates :status,
            presence: true,
            inclusion: {
              in: STATUSES
            }

  validates :expira_em,
            presence: true

  generates_token_for :acceptance,
                      expires_in: 48.hours

  scope :aguardando, -> {
    where(status: "aguardando")
  }

  scope :expirados, -> {
    where(status: "expirado")
  }

  scope :vencidos, -> {
    aguardando.where("expira_em < ?", Time.current)
  }

  def aguardando?
    status == "aguardando"
  end

  def aceito?
    status == "aceito"
  end

  def expirado?
    status == "expirado"
  end

  def cancelado?
    status == "cancelado"
  end

  def expirou?
    expira_em <= Time.current
  end

  def pendente?
    aguardando? && !expirou?
  end
end