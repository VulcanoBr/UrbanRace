class NpsResponse < ApplicationRecord
  belongs_to :athlete
  belongs_to :event
  belongs_to :result

  validates :nota_geral, inclusion: 0..10
end