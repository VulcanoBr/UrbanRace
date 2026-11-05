class Route < ApplicationRecord
  belongs_to :event
  belongs_to :distance

  has_many :waypoints, dependent: :destroy

  validates :geojson_traca, presence: true
  validates :distance_id, uniqueness: { scope: :event_id, message: "já possui um percurso cadastrado" }

  validate :distance_belongs_to_event

  private

  def distance_belongs_to_event
    return unless event.present? && distance.present?

    unless distance.event_id == event_id
      errors.add(
        :distance,
        "não pertence ao evento"
      )
    end
  end
end