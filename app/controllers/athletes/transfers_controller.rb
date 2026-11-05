## app/controllers/athletes/transfers_controller.rb

class Athletes::TransfersController < Athletes::BaseController
  before_action :set_registration
  before_action :verificar_elegibilidade

  def new
    @transfer_form = Athletes::TransferForm.new(
      registration_id: @registration.id,
      athlete_origem_id: Current.user.id
    )
  end

  def create
    @transfer_form = Athletes::TransferForm.new(
      transfer_params.merge(
        registration_id: @registration.id,
        athlete_origem_id: Current.user.id
      )
    )

    if @transfer_form.save

      if @transfer_form.destinatario_ja_cadastrado?
        redirect_to athletes_area_do_corredor_path,
                    notice: "Vaga transferida com sucesso! O atleta destinatário foi notificado por e-mail."
      else
        redirect_to athletes_area_do_corredor_path,
                    notice: "Convite enviado! O destinatário tem 48 horas para aceitar a transferência."
      end

    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_registration
    @registration = Current.user
      .registrations
      .includes(
        :event,
        :distance,
        :category,
        :athlete_checkins,
        :payment
      )
      .find(params[:registration_id])

  rescue ActiveRecord::RecordNotFound
    redirect_to athletes_root_path,
                alert: "Inscrição não encontrada."
  end

  def verificar_elegibilidade
    problemas = []

    unless @registration.confirmado?
      problemas << "Apenas inscrições confirmadas (pagas) podem ser transferidas."
    end

    if @registration.athlete_checkins.exists?
      problemas << "Você já realizou check-in neste evento."
    end

    if @registration.event.finished? ||
       @registration.event.cancelled?

      problemas << "Este evento está finalizado ou cancelado."
    end

    if @registration.transferido?
      problemas << "Esta inscrição já foi transferida."
    end

    if problemas.any?
      redirect_to athletes_registration_path(@registration),
                  alert: problemas.first
    end
  end

  def transfer_params
    params
      .require(:athletes_transfer_form)
      .permit(
        :cpf_destino,
        :email_destino
      )
  end
end