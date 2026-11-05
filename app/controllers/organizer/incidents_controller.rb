class Organizer::IncidentsController < Organizer::BaseController
  before_action :set_event

  def index
    @incidents = @event.incidents.includes(registration: :athlete).order(ocorrida_em: :desc)
  end

  def show
    @incident = @event.incidents.find(params[:id])
  end

  def update
    @incident = @event.incidents.find(params[:id])
    if @incident.update(params.require(:incident).permit(:status))
      redirect_to organizer_event_incident_path(@event, @incident), notice: "Status atualizado."
    end
  end

  private

  def set_event
    @event = Current.user.events.find_by!(slug_url: params[:event_id])
  end
end