# app/forms/organizer/supplier_form.rb
class Organizer::SupplierForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer
  attribute :razao_social, :string
  attribute :cnpj, :string
  attribute :contato, :string # Nome do responsável
  attribute :email_contato, :string
  attribute :phone_contato, :string
  attribute :tipo_servico, :string
  attribute :avaliacao_media, :decimal, default: 5.0

  validates :razao_social, :cnpj, :tipo_servico, :phone_contato, presence: true
  validates :email_contato, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validate :cnpj_valido_e_unico
  validate :phone_valido

  def persisted?
    id.present?
  end

  def self.from_model(supplier)
    new(
      id: supplier.id,
      razao_social: supplier.razao_social,
      cnpj: supplier.cnpj,
      contato: supplier.contato,
      email_contato: supplier.email_contato,
      phone_contato: supplier.phone_contato,
      tipo_servico: supplier.tipo_servico,
      avaliacao_media: supplier.avaliacao_media
    )
  end

  def save
    return false unless valid?

    supplier = id.present? ? Supplier.find(id) : Supplier.new
    
    supplier.assign_attributes(
      razao_social: razao_social,
      cnpj: cnpj.gsub(/\D/, ''), 
      contato: contato,
      email_contato: email_contato&.downcase&.strip,
      phone_contato: phone_contato&.gsub(/\D/, ''), # Salva apenas números
      tipo_servico: tipo_servico,
      avaliacao_media: avaliacao_media
    )

    if supplier.save
      @id = supplier.id
      true
    else
      promote_errors(supplier.errors)
      false
    end
  end

  private

  def phone_valido
    return if phone_contato.blank?

    # Remove tudo que não é número
    limpo = phone_contato.gsub(/\D/, '')

    # Verifica se o tamanho é diferente de 10 E diferente de 11
    unless limpo.length.in?([10, 11])
      errors.add(:phone_contato, "inválido. Deve conter 10 dígitos (fixo) ou 11 dígitos (celular) com DDD")
    end
  end

  def cnpj_valido_e_unico
    limpo = cnpj&.gsub(/\D/, '')
    errors.add(:cnpj, "deve conter 14 dígitos") if limpo.present? && limpo.length != 14
    errors.add(:cnpj, "já está cadastrado") if Supplier.where.not(id: id).exists?(cnpj: limpo)
  end

  def promote_errors(model_errors)
    model_errors.each { |e| errors.add(e.attribute, e.message) }
  end
end