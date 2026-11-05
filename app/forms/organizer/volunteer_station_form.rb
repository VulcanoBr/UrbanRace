# app/forms/organizer/volunteer_station_form.rb
class Organizer::VolunteerStationForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer
  attribute :event_id, :integer
  attribute :distance_id, :integer
  attribute :nome, :string
  attribute :tipo, :string
  attribute :km_posicao, :decimal
  attribute :vagas, :integer

  validates :nome, :tipo, :vagas, presence: true

  def persisted?
    id.present?
  end

  def save
    return false unless valid?
    station = id.present? ? VolunteerStation.find(id) : VolunteerStation.new
    station.assign_attributes(
      event_id: event_id,
      distance_id: distance_id,
      nome: nome,
      tipo: tipo,
      km_posicao: km_posicao,
      vagas: vagas
    )
    station.save
  end
end