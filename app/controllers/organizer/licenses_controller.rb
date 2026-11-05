class Organizer::LicensesController < Organizer::BaseController
  before_action :set_event
  before_action :set_license, only: %i[ edit update destroy ]

  def index
    @licenses = @event.licenses.order(prazo_aprovacao: :asc)
  end

  def new
    @license_form = Organizer::LicenseForm.new(event_id: @event.id)
  end

  def create
    @license_form = Organizer::LicenseForm.new(license_params.merge(event_id: @event.id))
    if @license_form.save
      redirect_to organizer_event_licenses_path(@event), notice: "Licença registrada com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @license_form = Organizer::LicenseForm.from_model(@license)
  end

  def update
    @license_form = Organizer::LicenseForm.from_model(@license)
    @license_form.assign_attributes(license_params)

    if @license_form.save
      redirect_to organizer_event_licenses_path(@event), notice: "Licença atualizada!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @license.destroy
    redirect_to organizer_event_licenses_path(@event), notice: "Licença removida.", status: :see_other
  end

  private

  def set_event
    # Buscamos pelo slug_url conforme definido no seu model Event
    @event = Current.user.events.find_by!(slug_url: params[:event_id])
  end

  def set_license
    @license = @event.licenses.find(params[:id])
  end

  def license_params
    params.require(:organizer_license_form).permit(:tipo, :orgao, :prazo_solicitacao, :prazo_aprovacao, :status, :documento_pdf)
  end
end