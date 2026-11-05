class Waypoint < ApplicationRecord
  belongs_to :route
  belongs_to :closed_by, class_name: 'Organizer', optional: true

  scope :abertos, -> { where(closed_at: nil) }
  scope :fechados, -> { where.not(closed_at: nil) }
  scope :chegada, -> { where(eh_chegada: true) }

  def aberto?
    closed_at.nil?
  end
end