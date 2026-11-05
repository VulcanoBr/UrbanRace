# app/forms/organizer/sponsor_contract_form.rb
class Organizer::SponsorContractForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer
  attribute :sponsor_id, :integer
  attribute :event_id, :integer
  attribute :cota
  attribute :valor_cota, :string # Recebemos como string para tratar formatação de moeda
  attribute :status, :string, default: "negociando"
  attribute :assinado_em, :date
  attribute :arquivo_pdf # Para Active Storage

  validates :sponsor_id, :event_id, :valor_cota, :status, presence: true

  def persisted?
    id.present?
  end

  def self.from_model(contract)
    new(
      id: contract.id,
      sponsor_id: contract.sponsor_id,
      event_id: contract.event_id,
      cota: contract.cota,
      valor_cota: contract.valor_cota,
      status: contract.status,
      assinado_em: contract.assinado_em
    )
  end

  def save
    return false unless valid?

    contract = id.present? ? SponsorContract.find(id) : SponsorContract.new
    
    # Converte "1.500,00" para 1500.00
    decimal_value = valor_cota.to_s.gsub('.', '').gsub(',', '.').to_f

    contract.assign_attributes(
      sponsor_id: sponsor_id,
      event_id: event_id,
      cota: cota,
      valor_cota: decimal_value,
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

  def promote_errors(model_errors)
    model_errors.each { |e| errors.add(e.attribute, e.message) }
  end
end