class Organizer::RegistrationsController < Organizer::BaseController

  before_action :set_registration, only: %i[show edit update destroy]

  
  def index
    @event = Event.find_by!(slug_url: params[:event_id]) if params[:event_id].present?

    @nome_atleta = params[:nome_atleta].to_s.strip

    @registrations = if @event
      @event.registrations
    else
      Registration.all
    end

    @registrations = @registrations
      .joins(:athlete)
      .includes(:athlete, :event, :category, :distance)
      .order(created_at: :desc)

    if @nome_atleta.present?
      @registrations = @registrations.where(
        "athletes.nome ILIKE ?",
        "%#{ActiveRecord::Base.sanitize_sql_like(@nome_atleta)}%"
      )
    end

    @registrations = @registrations.page(params[:page]).per(10)
  end

  def new
    @registration_form = Organizer::RegistrationForm.new(
      event_id:    params[:event_id],
      distance_id: params[:distance_id]
    )
  end

  def create
    @registration_form = Organizer::RegistrationForm.new(registration_params)

    if @registration_form.save
      redirect_to organizer_registration_path(@registration_form.id),
                  notice: "Inscrição realizada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @registration_form = Organizer::RegistrationForm.from_model(@registration)
  end

  def update
    @registration_form = Organizer::RegistrationForm.new(
      registration_params.merge(id: @registration.id)
    )
    if @registration_form.save
      redirect_to organizer_registration_path(@registration), notice: "Inscrição atualizada."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def show; end

  def destroy
    Distance.decrement_counter(:vagas_ocupadas, @registration.distance_id)
    @registration.destroy
    redirect_to organizer_registrations_path, notice: "Inscrição removida."
  end

  # Chamado via Turbo Stream quando evento OU distância muda
  def update_options
    @registration_form = Organizer::RegistrationForm.new(
      event_id:           params[:event_id].presence,
      distance_id:        params[:distance_id].presence,
      athlete_id:         params[:athlete_id].presence,   # preserva atleta selecionado
      selected_athlete_id:  params[:athlete_id].presence,
      selected_distance_id: params[:distance_id].presence
    )

    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  def set_registration
    @registration = Registration.find(params[:id])
  end

  def registration_params
    params.require(:organizer_registration_form).permit(
      :athlete_id, :event_id, :distance_id, :category_id, :lot_id,
      :status, :tamanho_kit, :numero_dorsal,
      :contato_emergencia, :fone_emergencia
    )
  end
end