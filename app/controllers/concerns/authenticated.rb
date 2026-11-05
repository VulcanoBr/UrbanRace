# app/controllers/concerns/authenticated.rb
module Authenticated
  extend ActiveSupport::Concern

  included do
    before_action :set_current_authenticated_session
    before_action :require_authentication
  end

  # ESTE BLOCO É A CHAVE: Ele torna o método disponível para a classe do Controller
  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def set_current_authenticated_session
    # Usa ::Current para garantir o escopo global do model
    if session_record = Session.find_by(id: cookies.signed[:session_id])
      Current.session = session_record
    end
  end

  def require_authentication
    unless Current.session
      # ── CORREÇÃO: só seta o flash se ainda não tiver um alert pendente ──
      flash[:alert] = "Você precisa entrar primeiro." unless flash[:alert].present?

      respond_to do |format|
        format.html { redirect_to main_app.new_session_path }
        format.json { head :unauthorized }
      end
    end
  end
end