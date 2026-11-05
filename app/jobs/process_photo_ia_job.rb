# app/jobs/process_photo_ia_job.rb
#
# Processa UMA foto: chama a IA, detecta dorsais e cria os vínculos N:N
# com as inscrições correspondentes (PhotoRegistration).
#
class ProcessPhotoIaJob < ApplicationJob
  queue_as :background

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(photo_id)
    photo = Photo.find_by(id: photo_id)
    return unless photo
    return if photo.reconhecido_ia?
    return unless photo.arquivo.attached?
    return if photo.foto_evento?   # Fotos de evento não passam por IA

    results = Operation::PhotoOcrService.call(photo)

    if results[:success] && results[:resultados].any?
      associar_dorsais(photo, results[:resultados])
    else
      # Registra falha mas não bloqueia — foto fica como "pendente"
      Rails.logger.info "[ProcessPhotoIaJob] Photo ##{photo_id}: #{results[:error]}"
    end
  end

  private

  def associar_dorsais(photo, resultados)
    # Para cada dorsal detectado, cria o vínculo com a inscrição (se existir)
    dorsais_associados = 0

    resultados.each do |resultado|
      registration = Registration.find_by(
        event_id:      photo.event_id,
        numero_dorsal: resultado[:dorsal_detectado]
      )
      next unless registration

      # find_or_create_by evita duplicatas se o job for reprocessado
      photo.photo_registrations.find_or_create_by!(
        registration: registration
      ) do |pr|
        pr.confianca_ocr = resultado[:confianca]
      end

      dorsais_associados += 1
    end

    # Marca a foto como identificada se ao menos 1 atleta foi vinculado
    if dorsais_associados > 0
      photo.update!(
        reconhecido_ia: true,
        confianca_ocr:  resultados.map { |r| r[:confianca] }.max
      )
      broadcast_update(photo)
    end
  end

  def broadcast_update(photo)
    Turbo::StreamsChannel.broadcast_replace_to(
      "event_#{photo.event_id}_photos",
      target:  dom_id(photo),
      partial: "organizer/photos/photo_card",
      locals:  { photo: photo }
    )
  end
end
