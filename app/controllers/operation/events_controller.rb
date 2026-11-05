module Operation
  class EventsController < ApplicationController
    layout "operation"
    include Authenticated

    before_action :ensure_organizer_access

    def index
      # Utilizamos o scope 'operáveis' para filtrar a data
      # E garantimos que apenas eventos publicados ou ativos apareçam (evita rascunhos)
      @events = Event.operaveis.where(status: [:published, :active, :finished])
      
      # Nota: Se você quiser que o Admin veja TODOS mesmo assim, use:
      # @events = Current.user.admin? ? Event.order(data_largada: :desc) : Event.operáveis
    end

    private

    def ensure_organizer_access
      # Verifica se o usuário logado é um Organizer (Admin ou Staff)
      unless Current.user.is_a?(Organizer)
        redirect_to root_path, alert: "Acesso restrito à equipe de operação."
      end
    end
  end
end