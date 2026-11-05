# app/forms/operation/checkin_form.rb
class Operation::CheckinForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :registration_id, :integer
  attribute :volunteer_station_id, :integer
  attribute :chip_code, :string
  attribute :offline, :boolean, default: false

  validates :registration_id, :volunteer_station_id, :chip_code, presence: true

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      registration = Registration.find(registration_id)
      
      # 1. Registra o Check-in
      AthleteCheckin.create!(
        registration_id: registration_id,
        volunteer_station_id: volunteer_station_id,
        realizado_em: Time.current,
        offline: offline,
        sincronizado: !offline
      )

      update_params = { status: :checado }
      update_params[:chip_code] = chip_code if chip_code.present?
      
      registration.update!(update_params)
    end
  rescue => e
    errors.add(:base, "Erro no check-in: #{e.message}")
    false
  end
end