# app/forms/athletes/nps_response_form.rb
class Athletes::NpsResponseForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :registration_id, :integer
  attribute :nota_geral, :integer
  attribute :nota_percurso, :integer
  attribute :nota_organizacao, :integer
  attribute :nota_estrutura, :integer
  attribute :nota_comunicacao, :integer
  attribute :comentario, :string

  validates :nota_geral, presence: true, inclusion: { in: 0..10 }
  validates :nota_percurso, :nota_organizacao, :nota_estrutura, :nota_comunicacao, inclusion: { in: 0..10 }, allow_nil: true

  def save
    return false unless valid?

    registration = Registration.find(registration_id)
    
    NpsResponse.create!(
      athlete_id: registration.athlete_id,
      event_id: registration.event_id,
      result_id: registration.result.id,
      nota_geral: nota_geral,
      nota_percurso: nota_percurso,
      nota_organizacao: nota_organizacao,
      nota_estrutura: nota_estrutura,
      nota_comunicacao: nota_comunicacao,
      comentario: comentario,
      respondido_em: Time.current
    )
  end
end