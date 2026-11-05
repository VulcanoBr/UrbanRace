class Organizer::CheckinsController < Organizer::BaseController
  before_action :set_event

  def index
    # Mostra estatísticas rápidas no topo
    @stats = {
      total: @event.registrations.confirmado.count,
      presentes: @event.registrations.where(status: :checked_in).count
    }
    
    # Se houver busca manual
    if params[:query].present?
      @registrations = @event.registrations.confirmado
                             .joins(:athlete)
                             .where("athletes.nome ILIKE ? OR athletes.cpf LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%")
    end
  end

  def create
    # Lógica de check-in disparada pelo Scanner ou botão manual
    registration = @event.registrations.find_by!(qr_code_hash: params[:qr_code_hash])
    
    if registration.update(status: :checked_in)
      render json: { success: true, athlete: registration.athlete.nome, dorsal: registration.numero_dorsal }
    else
      render json: { success: false, message: "Erro ao realizar check-in" }, status: :unprocessable_entity
    end
  end

  private

  def set_event
    @event = Event.find_by!(slug_url: params[:event_id])
  end
end