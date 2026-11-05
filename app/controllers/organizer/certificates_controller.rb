# app/controllers/organizer/certificates_controller.rb
class Organizer::CertificatesController < Organizer::BaseController
  before_action :set_event

  def create_batch
    # Verifica se existem resultados homologados para evitar processamento desnecessário
    if @event.results.homologados.exists?
      # Dispara o Job em massa
      BatchCertificateJob.perform_later(@event.id)
      
      redirect_to organizer_event_results_path(@event), 
                  notice: "O processamento dos certificados foi iniciado. Eles estarão disponíveis assim que forem gerados."
    else
      redirect_to organizer_event_results_path(@event), 
                  alert: "Não existem resultados homologados para gerar certificados."
    end
  end

  private

  def set_event
    @event = Current.user.events.find_by!(slug_url: params[:event_id])
  end
end