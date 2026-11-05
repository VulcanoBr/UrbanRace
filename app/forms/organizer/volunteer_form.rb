# app/forms/organizer/volunteer_form.rb
class Organizer::VolunteerForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer
  attribute :nome, :string
  attribute :email, :string
  attribute :telefone, :string
  attribute :funcao_preferida, :string

  validates :nome, :email, :telefone, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :email_unico
  validate :phone_valido

  def persisted?
    id.present?
  end


  def self.from_model(volunteer)
    new(
      id: volunteer.id,
      nome: volunteer.nome,
      email: volunteer.email,
      telefone: volunteer.telefone,
      funcao_preferida: volunteer.funcao_preferida
    )
  end

  def save
    return false unless valid?

    volunteer = id.present? ? Volunteer.find(id) : Volunteer.new
    
    volunteer.assign_attributes(
      nome: nome,
      email: email.downcase.strip,
      telefone: telefone.gsub(/\D/, ''), # Salva apenas números
      funcao_preferida: funcao_preferida
    )

    if volunteer.save
      @id = volunteer.id
      true
    else
      promote_errors(volunteer.errors)
      false
    end
  end

  private

  def phone_valido
    return if telefone.blank?

    # Remove tudo que não é número
    limpo = telefone.gsub(/\D/, '')

    # Verifica se o tamanho é diferente de 10 E diferente de 11
    unless limpo.length.in?([10, 11])
      errors.add(:telefone, "inválido. Deve conter 10 dígitos (fixo) ou 11 dígitos (celular) com DDD")
    end
  end

  def email_unico
    if Volunteer.where.not(id: id).exists?(email: email&.downcase&.strip)
      errors.add(:email, "já cadastrado como voluntário")
    end
  end

  def promote_errors(model_errors)
    model_errors.each { |e| errors.add(e.attribute, e.message) }
  end
end