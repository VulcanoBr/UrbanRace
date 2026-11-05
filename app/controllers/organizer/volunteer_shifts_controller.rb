# app/controllers/organizer/volunteer_shifts_controller.rb
class Organizer::VolunteerShiftsController < Organizer::BaseController
  before_action :set_event
  before_action :set_station
  before_action :set_shift, only: [:edit, :update, :destroy]

  def index
    @shifts = @station.volunteer_shifts.includes(:volunteer).page(params[:page]).per(10)
  end

  def new
    @shift_form = Organizer::VolunteerShiftForm.new(volunteer_station_id: @station.id)
  end

  def create
    @shift_form = Organizer::VolunteerShiftForm.new(shift_params.merge(event_id: @event.id, volunteer_station_id: @station.id))
    if @shift_form.save
      redirect_to organizer_event_volunteer_station_volunteer_shifts_path(@event, @station), notice: "Voluntário escalado!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @shift_form = Organizer::VolunteerShiftForm.from_model(@shift)
  end

  def update
    @shift_form = Organizer::VolunteerShiftForm.new(shift_params.merge(id: @shift.id, volunteer_station_id: @station.id))
    if @shift_form.save
      redirect_to organizer_event_volunteer_station_volunteer_shifts_path(@event, @station), notice: "Escala atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @shift.destroy
    redirect_to organizer_event_volunteer_station_volunteer_shifts_path(@event, @station), notice: "Voluntário removido da escala."
  end

  private

  def set_event
    @event = Current.user.events.find_by!(slug_url: params[:event_id])
  end

  def set_station
    @station = @event.volunteer_stations.find(params[:volunteer_station_id])
  end

  def set_shift
    @shift = @station.volunteer_shifts.find(params[:id])
  end

  def shift_params
    params.require(:organizer_volunteer_shift_form).permit(:volunteer_id, :turno, :status)
  end
end