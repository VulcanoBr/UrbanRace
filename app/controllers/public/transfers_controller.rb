class Public::TransfersController < ApplicationController
  allow_unauthenticated_access

  before_action :set_pending_transfer

  def show
    @athlete = Athlete.new
  end

  def accept
    begin

      atleta =
        Athletes::TransferRegistrationService.aceitar_convite(
          pending_transfer: @pending_transfer,
          athlete_attributes: athlete_params
        )

      redirect_to new_session_path,
                  notice: "Cadastro concluído e vaga recebida! Faça login para acessar."

    rescue Athletes::TransferRegistrationService::TransferError => e

      @athlete = Athlete.new(
        athlete_params
      )

      @athlete.cpf =
        @pending_transfer.cpf_destino

      @athlete.email_address =
        @pending_transfer.email_destino

      @athlete.errors.add(
        :base,
        e.message
      )

      render :show,
             status: :unprocessable_entity
    end
  end

  private

  def set_pending_transfer
    @pending_transfer =
      PendingTransfer.find_by_token_for(
        :acceptance,
        params[:token]
      )

    unless @pending_transfer&.aguardando?
      redirect_to root_path,
                  alert: "Este convite não é mais válido."

      return
    end

    if @pending_transfer.expirou?
      @pending_transfer.update!(
        status: "expirado"
      )

      redirect_to root_path,
                  alert: "Este convite expirou."
    end
  end

  def athlete_params
    params
      .require(:athlete)
      .permit(
        :nome,
        :nascimento,
        :sexo,
        :password,
        :password_confirmation
      )
  end
end