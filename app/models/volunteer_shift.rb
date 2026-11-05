class VolunteerShift < ApplicationRecord
  belongs_to :volunteer_station
  belongs_to :volunteer

  enum :turno, { manha: "morning", tarde: "afternoon", noite: "night", integral: "full_day" }
  enum :status, { pendente: "pending", confirmado: "confirmed", cancelado: "cancelled" }, default: "pending"

  validates :turno, presence: true
end