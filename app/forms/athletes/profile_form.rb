# app/forms/athletes/profile_form.rb
class Athletes::ProfileForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :athlete_id, :integer
  attribute :nome, :string
  attribute :telefone, :string
  attribute :password, :string
  attribute :password_confirmation, :string

  validates :nome, :telefone, presence: true
  validates :password, confirmation: true, length: { minimum: 8 }, allow_blank: true
  validate :phone_valido

  def self.from_model(athlete)
    new(athlete_id: athlete.id, nome: athlete.nome, telefone: athlete.telefone)
  end

  def save
    return false unless valid?
    athlete = Athlete.find(athlete_id)
    athlete.assign_attributes(nome: nome, telefone: telefone.gsub(/\D/,''))
    athlete.password = password if password.present?
    athlete.save
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
end