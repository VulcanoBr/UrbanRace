class SupplierContract < ApplicationRecord
  belongs_to :supplier
  belongs_to :event

  has_many :supplier_deliveries, dependent: :destroy

  has_one_attached :arquivo_pdf

  enum :status, {
    negociacao: "negotiating",
    assinado: "signed",
    concluido: "completed",
    cancelado: "cancelled"
  }

  validates :supplier,
            presence: true

  validates :event,
            presence: true

  validates :valor,
            presence: true,
            numericality: {
              greater_than: 0
            }

  validates :status,
            presence: true,
            inclusion: {
              in: statuses.keys
            }

  validates :assinado_em,
            presence: true,
            if: :assinado?

  validate :assinado_em_nao_pode_ser_futuro,
           if: :assinado_em?

  private

  def assinado_em_nao_pode_ser_futuro
    return unless assinado_em > Time.current

    errors.add(
      :assinado_em,
      "não pode ser uma data futura"
    )
  end
end