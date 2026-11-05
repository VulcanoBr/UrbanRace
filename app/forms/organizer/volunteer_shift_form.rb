# app/forms/organizer/volunteer_shift_form.rb
class Organizer::VolunteerShiftForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id,                   :integer
  attribute :volunteer_id,         :integer
  attribute :volunteer_station_id, :integer
  attribute :event_id,             :integer   # ← FALTAVA este atributo
  attribute :turno,                :string
  attribute :status,               :string, default: "pending"

  validates :volunteer_id, :volunteer_station_id, :turno, :status, presence: true
  validate  :vagas_disponiveis_no_posto, if: :new_record?

  def persisted?
    id.present?
  end

  def self.from_model(shift)
    new(
      id:                   shift.id,
      volunteer_id:         shift.volunteer_id,
      volunteer_station_id: shift.volunteer_station_id,
      turno:                shift.turno,
      status:               shift.status
    )
  end

  def save
    return false unless valid?

    shift = id.present? ? VolunteerShift.find(id) : VolunteerShift.new
    shift.assign_attributes(
      volunteer_id:         volunteer_id,
      volunteer_station_id: volunteer_station_id,
      turno:                turno,
      status:               status
    )

    if shift.save
      @id = shift.id
      true
    else
      promote_errors(shift.errors)
      false
    end
  end

  def new_record?
    id.blank?
  end

  private

  def vagas_disponiveis_no_posto
    return if volunteer_station_id.blank?
    station = VolunteerStation.find_by(id: volunteer_station_id)
    return unless station
    if station.volunteer_shifts.count >= station.vagas
      errors.add(:base, "Este posto já atingiu o limite de voluntários.")
    end
  end

  def promote_errors(model_errors)
    model_errors.each { |e| errors.add(e.attribute, e.message) }
  end
end