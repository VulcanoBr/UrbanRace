# app/forms/organizer/supplier_contract_form.rb

class Organizer::SupplierContractForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer
  attribute :supplier_id, :integer
  attribute :event_id, :integer
  attribute :valor, :string

  attribute :status,
            :string,
            default: "negociacao"

  attribute :assinado_em, :date
  attribute :arquivo_pdf

  validates :supplier_id,
            presence: true

  validates :event_id,
            presence: true

  validates :valor,
            presence: true

  validates :status,
            presence: true,
            inclusion: {
              in: SupplierContract.statuses.keys
            }

  validate :valor_deve_ser_maior_que_zero

  def persisted?
    id.present?
  end

  def self.from_model(contract)
    new(
      id: contract.id,
      supplier_id: contract.supplier_id,
      event_id: contract.event_id,
      valor: contract.valor,
      status: contract.status,
      assinado_em: contract.assinado_em
    )
  end

  def save
    return false unless valid?

    contract =
      if id.present?
        SupplierContract.find(id)
      else
        SupplierContract.new
      end

    decimal_value = parse_valor

    contract.assign_attributes(
      supplier_id: supplier_id,
      event_id: event_id,
      valor: decimal_value,
      status: status,
      assinado_em: assinado_em
    )

    contract.arquivo_pdf.attach(arquivo_pdf) if arquivo_pdf.present?

    if contract.save
      @id = contract.id

      true
    else
      promote_errors(contract.errors)

      false
    end
  end

  private

  def parse_valor
    valor
      .to_s
      .gsub(".", "")
      .gsub(",", ".")
      .to_d
  end

  def valor_deve_ser_maior_que_zero
    return if valor.blank?

    decimal_value = parse_valor

    return if decimal_value > 0

    errors.add(
      :valor,
      "deve ser maior que zero"
    )
  rescue ArgumentError
    errors.add(
      :valor,
      "deve ser um valor válido"
    )
  end

  def promote_errors(model_errors)
    model_errors.each do |error|
      errors.add(
        error.attribute,
        error.message
      )
    end
  end
end