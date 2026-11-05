# app/forms/athletes/privacy_request_form.rb
class Athletes::PrivacyRequestForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :password, :string
  attribute :confirm_erasure, :boolean
  attribute :athlete_id, :integer

  validates :password, presence: true
  validates :confirm_erasure, acceptance: true

  def process
    return false unless valid?
    
    athlete = Athlete.find(athlete_id)
    if athlete.authenticate(password)
      Athletes::PrivacyService.new(athlete).anonymize_data!
      true
    else
      errors.add(:password, "está incorreta")
      false
    end
  end
end