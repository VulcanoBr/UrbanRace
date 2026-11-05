# app/forms/organizer/sponsor_form.rb
class Organizer::SponsorForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer
  attribute :nome, :string
  attribute :cnpj, :string
  attribute :contato, :string
  attribute :email_contato, :string
  attribute :phone_contato, :string
  attribute :website, :string
  attribute :ativo, :boolean, default: true
  attribute :logo # Active Storage

  validates :nome, :cnpj, :email_contato,  :phone_contato, presence: true
  validates :email_contato, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  validate :cnpj_valido_e_unico
  validate :phone_valido

  def persisted?
    id.present?
  end

  def self.from_model(sponsor)
    new(
      id: sponsor.id,
      nome: sponsor.nome,
      cnpj: sponsor.cnpj,
      contato: sponsor.contato,
      email_contato: sponsor.email_contato,
      phone_contato: sponsor.phone_contato,
      website: sponsor.website,
      ativo: sponsor.ativo
    )
  end

  def save
    return false unless valid?

    sponsor = id.present? ? Sponsor.find(id) : Sponsor.new
    
    # Lógica de link de indicação única
    link = "ref_#{SecureRandom.alphanumeric(6).downcase}" if sponsor.new_record?

    sponsor.assign_attributes(
      nome: nome,
      cnpj: cnpj&.gsub(/\D/, ''), # Apenas números
      contato: contato,
      email_contato: email_contato,
      phone_contato: phone_contato&.gsub(/\D/, ''),
      website: website,
      ativo: ativo,
      link_indicacao: link || sponsor.link_indicacao
    )

    sponsor.logo.attach(logo) if logo.present?

    if sponsor.save
      @id = sponsor.id
      true
    else
      promote_errors(sponsor.errors)
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
    errors.add(:cnpj, "já está cadastrado") if Sponsor.where.not(id: id).exists?(cnpj: limpo)
  end

  def promote_errors(model_errors)
    model_errors.each { |e| errors.add(e.attribute, e.message) }
  end
end