# app/services/operation/photo_ocr_service.rb
#
# Simula (ou chama de verdade) a API de IA para detectar dorsais em uma foto.
# Retorna ARRAY de dorsais detectados — uma foto pode ter vários atletas.
#
# Para integrar com Google Vision API de verdade:
#   response = Google::Cloud::Vision.image_annotator.text_detection(image: photo.arquivo.download)
#   texts = response.responses.first.text_annotations.map(&:description)
#
class Operation::PhotoOcrService
  def self.call(photo)
    new(photo).call
  end

  def initialize(photo)
    @photo = photo
  end

  def call
    # Simula latência de API externa
    sleep(1.5)

    dorsais_existentes = @photo.event.registrations.pluck(:numero_dorsal).compact
    return { success: false, error: "Sem inscrições no evento" } if dorsais_existentes.empty?

    # Simula 85% de chance de detectar ao menos um dorsal
    return { success: false, error: "Nenhum dorsal detectado" } if rand(1..100) > 85

    # Simula detectar entre 1 e 3 dorsais por foto (realístico: 1 foto pode ter N atletas)
    quantidade_detectada = [1, 1, 1, 2, 3].sample  # peso maior para 1 atleta
    dorsais_detectados   = dorsais_existentes.sample(quantidade_detectada)

    # Retorna array de resultados, um por dorsal detectado
    resultados = dorsais_detectados.map do |dorsal|
      {
        dorsal_detectado: dorsal,
        confianca:        rand(70..99)
      }
    end

    {
      success:    true,
      resultados: resultados   # Array: [{dorsal_detectado:, confianca:}, ...]
    }
  end
end
