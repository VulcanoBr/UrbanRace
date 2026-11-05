class Organizer::VolunteerStationsController < Organizer::BaseController
  before_action :set_event
  before_action :set_station, only: %i[ show edit update destroy ]

  def index
    @stations = @event.volunteer_stations.includes(:distance, :volunteer_shifts).order(:km_posicao)
  end

  def show
    # Mostra os voluntários atualmente escalados neste posto
    @shifts = @station.volunteer_shifts.includes(:volunteer)
  end

  def new
    @station_form = Organizer::VolunteerStationForm.new(event_id: @event.id)
  end

  def create
    @station_form = Organizer::VolunteerStationForm.new(station_params.merge(event_id: @event.id))
    if @station_form.save
      redirect_to organizer_event_volunteer_stations_path(@event), notice: "Posto de trabalho criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @station_form = Organizer::VolunteerStationForm.new(
      id: @station.id,
      event_id: @event.id,
      distance_id: @station.distance_id,
      nome: @station.nome,
      tipo: @station.tipo,
      km_posicao: @station.km_posicao,
      vagas: @station.vagas
    )
  end

  def update
    @station_form = Organizer::VolunteerStationForm.new(station_params.merge(id: @station.id, event_id: @event.id))
    if @station_form.save
      redirect_to organizer_event_volunteer_station_path(@event, @station), notice: "Posto atualizado!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @station.destroy
    redirect_to organizer_event_volunteer_stations_path(@event), notice: "Posto removido.", status: :see_other
  end

  private

  def set_event
    # @event = Event.find(params[:event_id])
    @event = Current.user
             .events
              .find_by!(slug_url: params[:event_id])
  end

  def set_station
    @station = @event.volunteer_stations.find(params[:id])
  end

  def station_params
    params.require(:organizer_volunteer_station_form).permit(:event_id, :distance_id, :nome, :tipo, :km_posicao, :vagas)
  end
end