# app/controllers/operation/broadcasts_controller.rb
module Operation
  class BroadcastsController < BaseController
    before_action :set_event

    def index
      # Pegamos as mensagens do evento (Gerais ou específicas para o posto do voluntário se tivéssemos essa info na sessão)
      # Filtramos apenas as enviadas nas últimas 24h para manter o mural limpo
      @messages = @event.broadcast_messages
                        .where("sent_at > ?", 24.hours.ago)
                        .order(sent_at: :desc)
    end

    def confirm
      @message = @event.broadcast_messages.find(params[:id])
      
      # SALVA NO BANCO: Agora a mudança é permanente
      @message.update(lida_em: Time.current)

      # 1. Atualiza o Admin em tempo real
      Turbo::StreamsChannel.broadcast_replace_to(
        "event_#{@event.id}_broadcasts",
        target: "status_#{helpers.dom_id(@message)}",
        html: "<span class=\"text-[8px] font-black uppercase text-green-600 bg-green-50 px-2 py-1 rounded-full\">✓ Lida na Estação</span>".html_safe
      )

      # 2. Responde para o Staff que clicou
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            helpers.dom_id(@message, :button),
            html: "<span class=\"text-[9px] font-black text-green-600 uppercase\">Confirmado ✓</span>".html_safe
          )
        end
      end
    end
  end
end