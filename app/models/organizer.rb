class Organizer < ApplicationRecord
  has_secure_password
  has_many :sessions, as: :user, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :managed_incidents, class_name: 'Incident', foreign_key: :organizer_id

  enum :role, { admin: "admin", staff: "staff" }, default: "staff"

  validates :email_address, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, allow_nil: true, length: { minimum: 8 }
  validates :role, presence: true

  normalizes :email_address, with: ->(email) { email.strip.downcase }

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_digest
  end

  def display_name
    name
  end

end