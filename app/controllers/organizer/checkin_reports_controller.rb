class Organizer::CheckinReportsController < Organizer::BaseController
  before_action :set_event

  def index
    @registrations = @event.registrations.includes(:athlete, :category)
    
    # Filtros para o supervisor
    @registrations = @registrations.where(status: params[:status]) if params[:status].present?
    @registrations = @registrations.where(category_id: params[:category_id]) if params[:category_id].present?
    
    @stats = {
      total: @registrations.count,
      presentes: @registrations.where(status: :checked_in).count,
      ausentes: @registrations.where(status: :confirmed).count # Inscritos que não chegaram
    }
  end

  private
  def set_event
    @event = Event.find_by!(slug_url: params[:event_id])
  end
end