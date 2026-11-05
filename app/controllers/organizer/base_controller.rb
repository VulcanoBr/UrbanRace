# app/controllers/organizer/base_controller.rb
class Organizer::BaseController < ApplicationController
  layout "admin" # Usa o layout que criamos anteriormente
  
  before_action :require_organizer
  before_action :ensure_admin_access # Nova trava
  before_action :set_current_event, if: -> { params[:event_id].present? || params[:id].present? && controller_name != "queues" }

  private

  def require_organizer
    unless Current.user.is_a?(Organizer)
      redirect_to new_session_path, alert: "Acesso restrito a organizadores."
    end
  end

  def set_current_event
    @current_event = Organizer::EventScopeService.new(Current.user).active_event  # Organizer::EventScopeService.active_event(session, Current.user)
  end

  def ensure_admin_access
    unless Current.user.is_a?(Organizer) && Current.user.admin?
      redirect_to root_path, alert: "Acesso restrito a administradores."
    end
  end
end
