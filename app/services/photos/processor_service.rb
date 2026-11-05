# app/services/photos/processor_service.rb
class Photos::ProcessorService
  def self.process_photo(photo_id)
    photo = Photo.find(photo_id)
    return if photo.reconhecido_ia?

    # 1. Simulação de chamada de API de IA / OCR
    # Na vida real: result = GoogleVision.detect_text(photo.url)
    detected_numbers = ["152", "184"] # Números detectados na imagem

    # 2. Associa a foto às inscrições encontradas no evento
    detected_numbers.each do |number|
      registration = Registration.find_by(event_id: photo.event_id, numero_dorsal: number)
      if registration
        # Criamos uma cópia ou associação da foto para o atleta
        # Aqui, como o ERD simplificado tem inscricao_id na Foto, 
        # atualizamos a foto principal ou criamos registros de junção
        photo.update!(
          registration: registration,
          reconhecido_ia: true,
          confianca_ocr: 95
        )
      end
    end
  end
end