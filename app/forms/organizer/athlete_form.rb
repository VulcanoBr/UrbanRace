# app/forms/organizer/athlete_form.rb
class Organizer::AthleteForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id
  attribute :nome, :string
  attribute :email_address, :string
  attribute :cpf, :string
  attribute :nascimento, :date
  attribute :sexo, :string
  attribute :telefone, :string
  attribute :password, :string
  attribute :password_confirmation, :string

  validates :nome, :email_address, :cpf, :nascimento, :telefone, presence: true
  validates :email_address, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, confirmation: true, length: { minimum: 8 }, if: -> { password.present? || id.blank? }
  validates :cpf, cpf: true
  
  # Validação de unicidade customizada para o form object
  validate :uniqueness_of_email_and_cpf
  validate :phone_valido

  def persisted?
    id.present?
  end

  def self.from_model(athlete)
    new(
      id: athlete.id,
      nome: athlete.nome,
      email_address: athlete.email_address,
      cpf: athlete.cpf,
      nascimento: athlete.nascimento,
      sexo: athlete.sexo,
      telefone: athlete.telefone
    )
  end

  def save
    return false unless valid?

    athlete = id.present? ? Athlete.find(id) : Athlete.new
    
    athlete.assign_attributes(
      nome: nome,
      email_address: email_address.downcase.strip,
      cpf: cpf.gsub(/\D/, ''), # Remove pontos e traços
      nascimento: nascimento,
      sexo: sexo,
      telefone: telefone
    )

    athlete.password = password if password.present?

    if athlete.save
      @id = athlete.id
      true
    else
      promote_errors(athlete.errors)
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

  def uniqueness_of_email_and_cpf
    if Athlete.where.not(id: id).exists?(email_address: email_address&.downcase)
      errors.add(:email_address, "já está em uso")
    end
    if Athlete.where.not(id: id).exists?(cpf: cpf&.gsub(/\D/, ''))
      errors.add(:cpf, "já está cadastrado")
    end
  end

  def promote_errors(model_errors)
    model_errors.each { |e| errors.add(e.attribute, e.message) }
  end
end