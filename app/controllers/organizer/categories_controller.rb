class Organizer::CategoriesController < Organizer::BaseController

  before_action :set_distance, only: %i[ index new create ]

  before_action :set_category, only: %i[   show edit update destroy ]

  def index
    @categories =
      @distance
        .categories
        .includes(:registrations)
        .ordered
  end
  
  def show
  end

  def new
    @category_form =
      Organizer::CategoryForm.new(
        distance_id: @distance.id
      )
  end

  def create
    @category_form =
      Organizer::CategoryForm.new(
        category_params.merge(
          distance_id: @distance.id
        )
      )

    if @category_form.save
      redirect_to organizer_distance_categories_path(@distance), notice: "Categoria criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @category_form =
      Organizer::CategoryForm.from_model(
        @category
      )
  end

  def update
    @category_form =
      Organizer::CategoryForm.new(
        category_params.merge(
          id: @category.id,
          distance_id: @category.distance_id
        )
      )

    if @category_form.save
      redirect_to organizer_distance_categories_path(@category.distance), notice: "Categoria atualizada com sucesso."
    else
      flash.now[:alert] = "Corrija os erros abaixo."

      render :edit,
            status: :unprocessable_entity
    end
  end

  def destroy
    distance = @category.distance

    @category.destroy

    redirect_to organizer_distance_path(distance),
                notice: "Categoria removida.",
                status: :see_other
  end

  private

  def set_distance
    @distance =
      Distance.find(params[:distance_id])
  end

  def set_category
    @category =  Category
                  .joins(distance: :event)
                  .where(events: {
                    organizer_id: Current.user.id
                  })
                  .includes(:distance)
                  .find(params[:id])
  end

  def category_params
    params
      .require(:organizer_category_form)
      .permit(
        :nome,
        :sexo,
        :idade_min,
        :idade_max
      )
  end
end