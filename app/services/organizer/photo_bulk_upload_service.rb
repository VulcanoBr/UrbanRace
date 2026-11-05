# app/services/organizer/photo_bulk_upload_service.rb
class Organizer::PhotoBulkUploadService
  def self.call(event_id, files, tipo: "atleta")
    new(event_id, files, tipo: tipo).call
  end

  def initialize(event_id, files, tipo:)
    @event_id = event_id
    @files    = Array(files).select { |f| f.respond_to?(:size) && f.size > 0 }
    @tipo     = tipo
  end

  def call
    return false if @files.empty?

    # Usar transação para evitar registros "órfãos" sem arquivo
    Photo.transaction do
      @files.each do |file|
        photo = Photo.new(
          event_id:       @event_id,
          tipo:           @tipo,
          enviada_em:     Time.current,
          reconhecido_ia: false
        )
        # Anexa o arquivo ao objeto em memória
        photo.arquivo.attach(file)
        
        # Salva tudo junto
        if photo.save
          ProcessPhotoIaJob.perform_later(photo.id) if @tipo == "atleta"
        end
      end
    end
    true
  rescue => e
    Rails.logger.error "[PhotoBulkUploadService] #{e.message}"
    false
  end
end