class Organizer::LicenseForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer
  attribute :event_id, :integer
  attribute :tipo, :string
  attribute :orgao, :string
  attribute :prazo_solicitacao, :date
  attribute :prazo_aprovacao, :date
  attribute :status, :string
  attribute :documento_pdf # Campo para o arquivo

  validates :tipo, :orgao, :prazo_aprovacao, :status, presence: true

  def persisted?
    id.present?
  end

  def assign_attributes(new_attributes = {})
    new_attributes.each do |key, value|
      public_send("#{key}=", value) if respond_to?("#{key}=")
    end
  end

  def self.from_model(license)
    new(
      id: license.id,
      event_id: license.event_id,
      tipo: license.tipo,
      orgao: license.orgao,
      prazo_solicitacao: license.prazo_solicitacao,
      prazo_aprovacao: license.prazo_aprovacao,
      status: license.status
    )
  end

  def save
    return false unless valid?

    license = id.present? ? License.find(id) : License.new
    license.assign_attributes(
      event_id: event_id,
      tipo: tipo,
      orgao: orgao,
      prazo_solicitacao: prazo_solicitacao,
      prazo_aprovacao: prazo_aprovacao,
      status: status
    )

    # Anexa o arquivo se ele for enviado
    license.documento_pdf.attach(documento_pdf) if documento_pdf.present?

    if license.save
      @id = license.id
      true
    else
      promote_errors(license.errors)
      false
    end
  end

  private

  def promote_errors(model_errors)
    model_errors.each { |e| errors.add(e.attribute, e.message) }
  end
end