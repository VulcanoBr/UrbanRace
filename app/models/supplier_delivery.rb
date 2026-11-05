class SupplierDelivery < ApplicationRecord
  belongs_to :supplier_contract

  delegate :supplier, to: :supplier_contract

  enum :status, {
    pending: "pending",
    scheduled: "scheduled",
    completed: "completed",
    cancelled: "cancelled"
  }, default: :pending

  validates :descricao,
            presence: true,
            length: { maximum: 255 }

  validates :data_prevista,
            presence: true

  validates :status,
            presence: true,
            inclusion: {
              in: statuses.keys
            }

  validate :data_real_obrigatoria_quando_concluida
  validate :data_real_ausente_quando_nao_concluida

  scope :upcoming, -> {
    where(status: %w[pending scheduled])
      .where("data_prevista >= ?", Date.current)
      .order(:data_prevista)
  }

  scope :overdue, -> {
    where(status: %w[pending scheduled])
      .where("data_prevista < ?", Date.current)
      .order(:data_prevista)
  }

  scope :completed_deliveries, -> {
    completed.order(data_real: :desc)
  }

  def overdue?
    return false if completed?
    return false if cancelled?
    return false if data_prevista.blank?

    data_prevista < Date.current
  end

  def on_schedule?
    !completed? &&
      !cancelled? &&
      !overdue?
  end

  def situation
    return :cancelled if cancelled?
    return :completed if completed?
    return :overdue if overdue?

    :on_schedule
  end

  private

  def data_real_obrigatoria_quando_concluida
    return unless completed?
    return if data_real.present?

    errors.add(
      :data_real,
      "deve ser informada quando a entrega estiver concluída"
    )
  end

  def data_real_ausente_quando_nao_concluida
    return if data_real.blank?
    return if completed?

    errors.add(
      :data_real,
      "só pode ser informada quando a entrega estiver concluída"
    )
  end
end