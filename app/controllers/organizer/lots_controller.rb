class Organizer::LotsController < Organizer::BaseController
  before_action :set_distance,
                only: %i[
                  index
                  new
                  create
                    ]

  before_action :set_lot,
                only: %i[
                  show
                  edit
                  update
                  destroy
                ]

  def index
    @lots = @distance
              .lots
              .left_joins(:registrations)
              .select(
                "lots.*,
                COUNT(registrations.id) AS registrations_count"
              )
              .group("lots.id")
              .ordered
  end

  def show
  end

  def new
    @lot_form =
      Organizer::LotForm.new(
        distance_id: @distance.id,
        status: "active"
      )
  end

  def create
    @lot_form = Organizer::LotForm.new(lot_params.merge(distance_id: @distance.id))

    if @lot_form.save
      redirect_to organizer_distance_path(@distance), notice: "Lote criado com sucesso."
    else
      render :new,
             status: :unprocessable_entity
    end
  end

  def edit
    @lot_form =
      Organizer::LotForm.from_model(@lot)
  end

  def update
    @lot_form = Organizer::LotForm.new(lot_params.merge(id: @lot.id, distance_id: @lot.distance_id))

    if @lot_form.save
      redirect_to organizer_lot_path(@lot), notice: "Lote atualizado com sucesso."
    else
      flash.now[:alert] = "Não foi possível salvar as alterações."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    distance = @lot.distance

    @lot.destroy

    redirect_to organizer_distance_path(distance),
                notice: "Lote removido.",
                status: :see_other
  end

  private

  def set_distance
    @distance =
      Distance.find(params[:distance_id])
  end

  def set_lot
    @lot =
      Lot
        .joins(distance: :event)
        .where(events: {
          organizer_id: Current.user.id
        })
        .includes(:distance)
        .find(params[:id])
  end

  def lot_params
    params
      .require(:organizer_lot_form)
      .permit(
        :numero,
        :preco,
        :vagas,
        :abertura,
        :encerramento,
        :descricao_kit,
        :status
      )
  end
end