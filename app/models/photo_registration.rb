# Tabela de junção entre Photo e Registration (relação N:N)
# Uma foto pode ter vários atletas identificados.
# Um atleta pode aparecer em várias fotos.
class PhotoRegistration < ApplicationRecord
  belongs_to :photo
  belongs_to :registration

  validates :photo_id, uniqueness: {
    scope: :registration_id,
    message: "já está associada a esta inscrição"
  }
  validates :confianca_ocr, numericality: {
    only_integer: true,
    in: 0..100
  }, allow_nil: true

  scope :alta_confianca, -> { where("confianca_ocr >= 80") }
  scope :confirmados,    -> { where(confirmado_manualmente: true) }
end
