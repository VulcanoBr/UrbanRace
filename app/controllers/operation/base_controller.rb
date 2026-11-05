# app/controllers/operation/base_controller.rb
# app/controllers/operation/base_controller.rb
# app/controllers/operation/base_controller.rb
module Operation
  class BaseController < ApplicationController
    layout "operation"
    
    include Authenticated # Garante a sessão
    
    before_action :ensure_organizer_access
    before_action :set_event
    before_action :ensure_staff_or_admin_access

    private

    def ensure_organizer_access
      # Verifica se quem está logado é um organizador
      unless Current.user.is_a?(Organizer)
        redirect_to area_do_corredor_path, alert: "Acesso restrito ao Staff."
      end
    end

    def set_event
      # O segredo está aqui: buscar pelo slug_url que vem na rota
      @event = Event.find_by!(slug_url: params[:event_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to operation_events_path, alert: "Evento não encontrado."
    end

    def ensure_staff_or_admin_access
      unless Current.user.is_a?(Organizer) # Admin ou Staff são instâncias de Organizer
        redirect_to root_path, alert: "Acesso restrito à operação."
      end
    end
  end
end