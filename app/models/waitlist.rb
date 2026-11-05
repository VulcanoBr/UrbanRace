class Waitlist < ApplicationRecord
  belongs_to :athlete
  belongs_to :category
  belongs_to :distance
  belongs_to :event
  belongs_to :lot

  PRAZO_NOTIFICACAO_HORAS = 48

  STATUSES = %w[aguardando notificado convertido expirado].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :athlete_id, uniqueness: {
    scope:      :category_id,
    message:    "já está na lista de espera desta categoria",
    conditions: -> { where(status: "aguardando") }
  }

  scope :aguardando,       -> { where(status: "aguardando") }
  scope :por_distancia,    ->(distance_id) { where(distance_id: distance_id) }
  scope :por_posicao,      -> { order(:posicao) }

  def notificar_vaga_disponivel!
    return if status == "notificado"
    update!(status: "notificado")
    WaitlistMailer.vaga_disponivel(self).deliver_later
  end

  def expirado_por_prazo?
    return false unless status == "notificado"
    updated_at < PRAZO_NOTIFICACAO_HORAS.hours.ago
  end

  def horas_restantes
    return 0 unless status == "notificado"
    restante = (updated_at + PRAZO_NOTIFICACAO_HORAS.hours) - Time.current
    [restante / 3600, 0].max.round
  end
end