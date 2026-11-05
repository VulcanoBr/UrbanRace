class Volunteer < ApplicationRecord

  has_many :volunteer_shifts, dependent: :destroy

  validates :nome, :email, :telefone, presence: true
  validates :email, uniqueness: true
  
end
