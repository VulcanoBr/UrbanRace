class Payment < ApplicationRecord

  belongs_to :registration

  enum :metodo, {
        pix: "pix",
        cartao: "cartao",
        boleto: "boleto"
        }, prefix: true

  enum :status, {
        pendente: "pendente",
        pago: "pago",
        estornado: "estornado",
        cancelado: "cancelado"
        }, prefix: true

  validates :registration, presence: true

  validates :metodo, presence: true, inclusion: { in: metodos.keys }

  validates :status, presence: true, inclusion: { in: statuses.keys }

  validates :valor, presence: true, numericality: { greater_than: 0 }

  validates :gateway_provider, length: { maximum: 100 }, allow_blank: true

  validates :gateway_id, uniqueness: true, allow_blank: true

  validate :pago_em_required_when_paid
  validate :vencimento_required_for_boleto
  validate :pago_em_cannot_be_in_future

  scope :pendentes, -> { status_pendente }

  scope :pagos, -> { status_pago }

  scope :estornados, -> { status_estornado }

  scope :cancelados, -> { status_cancelado }

  scope :pix, -> { metodo_pix }

  scope :cartao, -> { metodo_cartao }

  scope :boletos, -> { metodo_boleto }

  scope :recentes, -> { order(created_at: :desc) }

  scope :vencidos, -> { status_pendente.where.not(vencimento: nil).where("vencimento < ?", Time.current) }

  def pago?
    status_pago?
  end

  def pendente?
    status_pendente?
  end

  def estornado?
    status_estornado?
  end

  def cancelado?
    status_cancelado?
  end

  def vencido?
    status_pendente? &&
    vencimento.present? &&
    vencimento < Time.current
  end

  def pode_ser_cancelado?
    status_pendente?
  end

  def pode_ser_estornado?
    status_pago?
  end

  def marcar_como_pago!
    update!(
    status: :pago,
    pago_em: Time.current
    )
  end

  def cancelar!
    return false unless pode_ser_cancelado?

    update!(
      status: :cancelado
    )
  end

  def estornar!
    return false unless pode_ser_estornado?

    update!(
      status: :estornado
    )
  end

  private

  def pago_em_required_when_paid
    return unless status_pago?
    return if pago_em.present?

    errors.add(
      :pago_em,
      "deve ser informado quando o pagamento estiver pago"
    )
  end

  def vencimento_required_for_boleto
    return unless metodo_boleto?
    return if vencimento.present?

    errors.add(
      :vencimento,
      "deve ser informado para pagamentos via boleto"
    )
  end

  def pago_em_cannot_be_in_future
    return if pago_em.blank?
    return unless pago_em > Time.current

    
    errors.add(
      :pago_em,
      "não pode estar no futuro"
    )
  end
end
