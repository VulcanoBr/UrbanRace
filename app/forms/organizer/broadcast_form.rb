class Organizer::BroadcastForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :event_id, :integer
  attribute :volunteer_station_id, :integer
  attribute :sender_id, :integer
  attribute :titulo, :string
  attribute :corpo, :string
  attribute :categoria, :string, default: "info"

  validates :titulo, :corpo, :categoria, :event_id, :sender_id, presence: true

  def save
    return false unless valid?

    # Corrigido para .call
    Organizer::BroadcastService.call(
      event_id: event_id,
      volunteer_station_id: volunteer_station_id,
      sender_id: sender_id,
      titulo: titulo,
      corpo: corpo,
      categoria: categoria
    )
  end
end