# app/controllers/organizer/photos_controller.rb
class Organizer::PhotosController < Organizer::BaseController
  before_action :set_event

  def index
    @photos_atletas = @event.photos.tipo_atleta.com_arquivo
                            .includes(photo_registrations: :registration)
                            .order(created_at: :desc)
                            .limit(60)
    @photos_evento  = @event.photos.tipo_evento.com_arquivo
                            .order(created_at: :desc)
                            .limit(60)

    # Dois forms separados com tipo pré-definido — evita ambiguidade
    @form_atleta = Organizer::PhotoUploadForm.new(event_id: @event.id, tipo: "atleta")
    @form_evento = Organizer::PhotoUploadForm.new(event_id: @event.id, tipo: "evento")

    @resumo = {
      total_atletas: @event.photos.tipo_atleta.count,
      identificadas: @event.photos.tipo_atleta.identificadas.count,
      pendentes:     @event.photos.tipo_atleta.pendentes.count,
      total_evento:  @event.photos.tipo_evento.count
    }
  end

  def bulk_upload
    tipo = params.dig(:organizer_photo_upload_form, :tipo).presence || "atleta"

    @form = Organizer::PhotoUploadForm.new(
      files:    photo_params[:files],
      event_id: @event.id,
      tipo:     tipo
    )

    if @form.save
      tipo_label = tipo == "atleta" ? "de atletas" : "do evento"
      aviso      = tipo == "atleta" ? "A IA está processando os dorsais." : "Fotos salvas com sucesso."
      redirect_to organizer_event_photos_path(@event),
                  notice: "Upload #{tipo_label} iniciado! #{aviso}"
    else
      # Reconstrói estado completo da index para re-renderizar
      @photos_atletas = @event.photos.tipo_atleta.com_arquivo
                              .includes(photo_registrations: :registration)
                              .order(created_at: :desc).limit(60)
      @photos_evento  = @event.photos.tipo_evento.com_arquivo
                              .order(created_at: :desc).limit(60)
      @form_atleta    = tipo == "atleta" ? @form : Organizer::PhotoUploadForm.new(event_id: @event.id, tipo: "atleta")
      @form_evento    = tipo == "evento" ? @form : Organizer::PhotoUploadForm.new(event_id: @event.id, tipo: "evento")
      @resumo         = { total_atletas: 0, identificadas: 0, pendentes: 0, total_evento: 0 }
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @photo = @event.photos.find(params[:id])
    @photo.destroy!
    redirect_to organizer_event_photos_path(@event), notice: "Foto removida."
  end

  private

  def set_event
    @event = Current.user.events.find_by!(slug_url: params[:event_id])
  end

  def photo_params
    params.require(:organizer_photo_upload_form).permit(files: [])
  end
end
