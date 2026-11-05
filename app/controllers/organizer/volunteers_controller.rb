class Organizer::VolunteersController < Organizer::BaseController
  before_action :set_volunteer, only: %i[edit update destroy assign_shift create_shift]
  
  def index
    @nome = params[:nome].to_s.strip
    @funcao_preferida = params[:funcao_preferida].to_s.strip

    @volunteers = Volunteer
      .includes(:volunteer_shifts)
      .order(nome: :asc)

    if @nome.present?
      @volunteers = @volunteers.where(
        "volunteers.nome ILIKE ?",
        "%#{ActiveRecord::Base.sanitize_sql_like(@nome)}%"
      )
    end

    if @funcao_preferida.present?
      @volunteers = @volunteers.where(
        "volunteers.funcao_preferida = ?",
        @funcao_preferida
      )
    end

    @funcoes_preferidas = Volunteer
      .where.not(funcao_preferida: [nil, ""])
      .distinct
      .order(:funcao_preferida)
      .pluck(:funcao_preferida)

    @volunteers = @volunteers
      .page(params[:page])
      .per(10)
  end

  def new
    @volunteer_form = Organizer::VolunteerForm.new
  end

  def create
    @volunteer_form = Organizer::VolunteerForm.new(volunteer_params)
    if @volunteer_form.save
      redirect_to organizer_volunteers_path, notice: "Voluntário cadastrado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @volunteer_form = Organizer::VolunteerForm.from_model(@volunteer)
  end

  def update
    @volunteer_form = Organizer::VolunteerForm.new(volunteer_params.merge(id: @volunteer.id))
    if @volunteer_form.save
      redirect_to organizer_volunteers_path, notice: "Dados do voluntário atualizados!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @volunteer.volunteer_shifts.any?
      redirect_to organizer_volunteers_path,
        alert: "Este voluntário possui escalas registradas e não pode ser removido."
    else
      @volunteer.destroy
      redirect_to organizer_volunteers_path,
        notice: "Voluntário removido.", status: :see_other
    end
  end

  def assign_shift
    @events     = Event.where(status: [:published, :active]).order(data_largada: :asc)
    @shift_form = Organizer::VolunteerShiftForm.new(volunteer_id: @volunteer.id)
  end

  # ← NOVA ACTION: recebe o POST do formulário
  def create_shift
    @shift_form = Organizer::VolunteerShiftForm.new(
      shift_params.merge(volunteer_id: @volunteer.id)
    )

    if @shift_form.save
      redirect_to organizer_volunteers_path,
        notice: "#{@volunteer.nome} escalado com sucesso!"
    else
      @events = Event.where(status: [:published, :active]).order(data_largada: :asc)
      render :assign_shift, status: :unprocessable_entity
    end
  end

  private

  def set_volunteer
    @volunteer = Volunteer.find(params[:id])
  end

  def volunteer_params
    params.require(:organizer_volunteer_form).permit(:nome, :email, :telefone, :funcao_preferida)
  end

  def shift_params
    params.require(:organizer_volunteer_shift_form)
          .permit(:volunteer_station_id, :event_id, :turno, :status)
  end
end