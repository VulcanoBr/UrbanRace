# app/forms/organizer/photo_upload_form.rb
class Organizer::PhotoUploadForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :event_id, :integer
  attribute :files
  attribute :tipo, :string, default: "atleta"

  TIPOS_VALIDOS = %w[atleta evento].freeze

  validates :event_id, presence: true
  validates :tipo, inclusion: { in: TIPOS_VALIDOS }
  validate  :arquivos_validos

  def save
    return false unless valid?
    Organizer::PhotoBulkUploadService.call(event_id, arquivos_limpos, tipo: tipo)
  end

  def arquivos_limpos
    Array(files).select { |f| f.respond_to?(:size) && f.size > 0 }
  end

  private

  def arquivos_validos
    errors.add(:files, "Selecione ao menos um arquivo") if arquivos_limpos.empty?
  end
end
