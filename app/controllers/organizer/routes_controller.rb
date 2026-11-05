# app/controllers/organizer/routes_controller.rb
class Organizer::RoutesController < Organizer::BaseController
  before_action :set_event
  before_action :set_route, only: %i[show edit update destroy]
  before_action :ensure_event_editable, only: %i[new create edit update destroy]

  def index
    @routes = @event.routes
                    .joins(:distance)
                    .includes(:distance)
                    .order("distances.km ASC")
  end

  def show
  end

  def new
    @route_form = Organizer::RouteForm.new(
      event_id: @event.id
    )

    @distances = @event.distances.order(:km)
  end

  def create
    @route_form = Organizer::RouteForm.new(
      route_params.merge(event_id: @event.id)
    )

    @distances = @event.distances.order(:km)

    if @route_form.save
      redirect_to organizer_event_route_path(
        @event,
        @route_form.route
      ), notice: "Percurso criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @route_form = Organizer::RouteForm.from_model(@route)
    @distances = @event.distances.order(:km)
  end

  def update
    @route_form = Organizer::RouteForm.new(
      route_params.merge(
        id: @route.id,
        event_id: @event.id
      )
    )

    @distances = @event.distances.order(:km)

    if @route_form.save
      redirect_to organizer_event_route_path(
        @event,
        @route_form.route
      ), notice: "Percurso atualizado com sucesso!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @route.destroy

    redirect_to organizer_event_routes_path(@event),
                notice: "Percurso removido.",
                status: :see_other
  end

  private

  def set_event
    @event = Current.user.events.find_by!(
      slug_url: params[:event_id]
    )
  end

  def set_route
    @route = @event.routes.find(params[:id])
  end

  def ensure_event_editable
    return unless @event.finished?

    redirect_to organizer_event_routes_path(@event),
                alert: "O percurso não pode ser alterado pois o evento já foi finalizado."
  end

  def route_params
    params.require(:organizer_route_form).permit(
      :distance_id,
      :geojson_traca,
      :pontos_apoio_json
    )
  end
end