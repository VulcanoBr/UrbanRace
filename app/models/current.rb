# app/models/current.rb
class Current < ActiveSupport::CurrentAttributes
  attribute :session

  delegate :user, to: :session, allow_nil: true

  def athlete
    user if user.is_a?(Athlete)
  end

  def organizer
    user if user.is_a?(Organizer)
  end
end