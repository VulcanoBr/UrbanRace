class AthleteCheckin < ApplicationRecord
  belongs_to :registration
  belongs_to :volunteer_station

  scope :sincronizados, -> { where(sincronizado: true) }
  scope :pendentes_sincronia, -> { where(sincronizado: false) }
end