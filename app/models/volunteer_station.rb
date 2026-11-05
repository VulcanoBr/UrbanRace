class VolunteerStation < ApplicationRecord
  belongs_to :event
  belongs_to :distance
  has_many :volunteer_shifts, dependent: :destroy
  has_many :athlete_checkins

  validates :nome, :km_posicao, presence: true
end