# app/controllers/operation/kit_deliveries_controller.rb
module Operation
  class KitDeliveriesController < EventsController
    before_action :set_event
    layout "operation"

    def index
      @registrations = @event.registrations.confirmado.includes(:athlete, :distance).joins(:athlete).order("athletes.nome ASC")
      
      if params[:query].present?
        q = "%#{params[:query]}%"
        @registrations = @registrations.where(
          "athletes.nome ILIKE ? OR athletes.cpf = ? OR registrations.numero_dorsal::text = ?", 
          q, params[:query], params[:query]
        )
      end

      @registrations = @registrations.page(params[:page]).per(10)
    end

    def show
      @registration = @event.registrations.find(params[:id])
    end

    def update
      @registration = @event.registrations.find(params[:id])
      
      if Operation::KitDeliveryService.call(@registration, kit_params)
        redirect_to operation_event_kit_deliveries_path(@event), notice: "Kit entregue para #{@registration.athlete.nome}!"
      else
        # IMPORTANTE: Recarrega os dados do banco para limpar as alterações temporárias que falharam
        @registration.reload 
        flash.now[:alert] = "Erro ao confirmar entrega. Verifique se o Mailer foi criado corretamente."
        render :show, status: :unprocessable_entity
      end
    end

    private

    def set_event
      @event = Event.find_by!(slug_url: params[:event_id])
    end

    def kit_params
      params.require(:registration).permit(:chip_code, :numero_dorsal)
    end
  end
end