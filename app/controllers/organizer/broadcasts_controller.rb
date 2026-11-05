class Organizer::BroadcastsController < Organizer::BaseController
  before_action :set_event

  def index
    @messages = @event.broadcast_messages.order(sent_at: :desc)
    @broadcast_form = Organizer::BroadcastForm.new(event_id: @event.id)
  end

  def create
    @broadcast_form = Organizer::BroadcastForm.new(broadcast_params.merge(
      event_id: @event.id,
      sender_id: Current.user.id
    ))

    if @broadcast_form.save
      redirect_to organizer_event_broadcasts_path(@event), notice: "Comunicado enviado com sucesso!"
    else
      @messages = @event.broadcast_messages.order(sent_at: :desc)
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Current.user.events.find_by!(slug_url: params[:event_id])
  end

  def broadcast_params
    params.require(:organizer_broadcast_form).permit(:titulo, :corpo, :categoria, :volunteer_station_id)
  end
end