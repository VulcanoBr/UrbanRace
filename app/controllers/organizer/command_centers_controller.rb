# app/controllers/organizer/command_centers_controller.rb
class Organizer::CommandCentersController < Organizer::BaseController
  before_action :set_event

  def show
    # Dados para o carregamento inicial
    @incidents = @event.incidents.order(ocorrida_em: :desc).limit(10)
    @stations = @event.volunteer_stations.includes(:athlete_checkins)
    
    # Estatísticas de fluxo
    @total_atletas = @event.registrations.confirmado.count
    @na_prova = @event.registrations.where(status: :checked_in).count # Simplificação para o Live
    @finalizados = @event.results.count
  end

  private

  def set_event
    @event = Event.find_by!(slug_url: params[:event_id])
  end
end