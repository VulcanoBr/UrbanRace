# app/controllers/operation/incidents_controller.rb
module Operation
  class IncidentsController < BaseController
    # before_action :set_event

    def new
      @incident_form = Operation::IncidentForm.new(event_id: @event.id)
    end

    def create
      @incident_form = Operation::IncidentForm.new(incident_params.merge(
        event_id: @event.id,
        organizer_id: Current.user.id
      ))

      if @incident_form.save
        # Se salvou, renderiza uma página de "Alerta Enviado" com os dados de emergência do atleta
        redirect_to success_operation_event_incident_path(@event, @incident_form.incident), status: :see_other
      else
        render :new, status: :unprocessable_entity
      end
    end

    def success
      @incident = @event.incidents.find(params[:id])
      @registration = @incident.registration
      # Se houver inscrição, preparamos os dados de emergência
      if @registration
        @emergency_info = {
          atleta: @registration.athlete.nome,
          contato: @registration.contato_emergencia,
          telefone: @registration.fone_emergencia
        }
      end
    end

    private

    def incident_params
      params.require(:operation_incident_form).permit(:dorsal, :tipo, :gravidade, :km_local, :descricao)
    end
  end
end