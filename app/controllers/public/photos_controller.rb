class Public::PhotosController < ApplicationController
  allow_unauthenticated_access only: :show

  def show
    @event = Event.find_by!(slug_url: params[:slug])
    
    # 1. Todas as fotos do tipo evento (Bastidores, Pódio, Largada)
    @event_photos = @event.photos.tipo_evento.com_arquivo.order(created_at: :desc)

    # 2. 12 fotos aleatórias de atletas para o mosaico público
    # Usamos RANDOM() no Postgres para diversificar a vitrine
    @athlete_photos = @event.photos.tipo_atleta.com_arquivo
                            .order("RANDOM()")
                            .limit(12)
  end
end