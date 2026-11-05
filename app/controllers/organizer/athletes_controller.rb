class Organizer::AthletesController < Organizer::BaseController
  before_action :set_athlete, only: %i[ edit update destroy history ]

  def index
    @athletes = Athlete.order(nome: :asc)

    if params[:query].present?
      @athletes = @athletes.search(params[:query].strip)
    end

    @athletes = @athletes.page(params[:page]).per(10)
  end

  def new
    @athlete_form = Organizer::AthleteForm.new
  end

  def create
    @athlete_form = Organizer::AthleteForm.new(athlete_params)

    if @athlete_form.save
      redirect_to organizer_athletes_path, notice: "Atleta cadastrado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @athlete_form = Organizer::AthleteForm.from_model(@athlete)
  end

  def update
    @athlete_form = Organizer::AthleteForm.new(athlete_params.merge(id: @athlete.id))

    if @athlete_form.save
      redirect_to organizer_athletes_path, notice: "Dados do atleta atualizados!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @athlete.registrations.any?
      redirect_to organizer_athletes_path, alert: "Não é possível excluir atleta com inscrições ativas."
    else
      @athlete.destroy
      redirect_to organizer_athletes_path, notice: "Atleta removido.", status: :see_other
    end
  end

  def history
    # Carrega inscrições que possuem resultado, trazendo as associações necessárias
    @registrations = @athlete.registrations
                             .joins(:result)
                             .includes(:event, :distance, :result)
                             .order("events.created_at DESC") # Ajuste para a coluna de data do seu evento
  end

  private

  def set_athlete
    @athlete = Athlete.find(params[:id])
  end

  def athlete_params
    params.require(:organizer_athlete_form).permit(:nome, :email_address, :cpf, :nascimento, :sexo, :telefone, :password, :password_confirmation)
  end
end