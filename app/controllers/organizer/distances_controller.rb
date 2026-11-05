class Organizer::DistancesController < Organizer::BaseController
  before_action :set_event,
                only: %i[
                  index
                  new
                  create
                ]

  before_action :set_distance,
                only: %i[
                  show
                  edit
                  update
                  destroy
                ]

  def index
    @distances =
      @event
        .distances
        .with_relations
        .ordered
  end

  def show
  end

  def new
    @distance_form =
      Organizer::DistanceForm.new(
        event_id: @event.id
      )
  end

  def create
    @distance_form =
      Organizer::DistanceForm.new(
        distance_params.merge(
          event_id: @event.id
        )
      )

    if @distance_form.save
      redirect_to organizer_event_distances_path(@event), notice: "Distância criada com sucesso."
    else
      render :new,
             status: :unprocessable_entity
    end
  end

  def edit
    @event = @distance.event
    @distance_form = Organizer::DistanceForm.from_model(@distance)
  end

  def update
    @event = @distance.event
    @distance_form =
      Organizer::DistanceForm.new(
        distance_params.merge(
          id: @distance.id,
          event_id: @distance.event_id
        )
      )

    if @distance_form.save
      redirect_to organizer_distance_path(
        @distance
      ),
      notice: "Distância atualizada."
    else
      render :edit,
             status: :unprocessable_entity
    end
  end

  def destroy
    event = @distance.event

    @distance.destroy

    redirect_to organizer_event_path(event),
                notice: "Distância removida.",
                status: :see_other
  end

  private

  def set_event
    @event =
      Current.user
             .events
              .find_by!(slug_url: params[:event_id])
  end

  def set_distance
    @distance =
      Distance.joins(:event)
              .where(
                events: {
                  organizer_id: Current.user.id
                }
              )
              .find(params[:id])
  end

  def distance_params
    params
      .require(:organizer_distance_form)
      .permit(
        :nome,
        :km,
        :vagas_total
      )
  end
end