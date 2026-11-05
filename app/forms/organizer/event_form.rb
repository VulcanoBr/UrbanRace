# app/forms/organizer/event_form.rb
class Organizer::EventForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer

  attribute :nome, :string
  attribute :descricao, :string

  attribute :cidade, :string
  attribute :estado, :string

  attribute :local_partida, :string

  attribute :data_largada, :date
  attribute :horario_largada, :time

  attribute :slug_url, :string
  attribute :status, :string, default: "draft"

  attribute :organizer_id, :integer

  attribute :kit_descricao, :string
  attribute :cronograma, :string
  attribute :instagram_url, :string
  attribute :whatsapp_contato, :string
  attribute :limite_atletas, :integer

  attr_accessor :banner
  attr_accessor :regulamento

  validates :nome, :cidade, :estado, :local_partida, :data_largada, 
            :horario_largada, :limite_atletas, presence: true
  validates :limite_atletas, numericality: { only_integer: true, greater_than: 0 }

  validates :slug_url, presence: true, format: { with: /\A[a-z0-9-]+\z/ }

  validates :descricao, length: { maximum: 5000 }

  def self.from_model(event)
    new(
      id: event.id,
      nome: event.nome,
      descricao: event.descricao,
      cidade: event.cidade,
      estado: event.estado,
      local_partida: event.local_partida,
      data_largada: event.data_largada,
      horario_largada: event.horario_largada,
      slug_url: event.slug_url,
      status: event.status,
      organizer_id: event.organizer_id,

      kit_descricao: event.kit_descricao,
      cronograma: event.cronograma,
      instagram_url: event.instagram_url,
      whatsapp_contato: event.whatsapp_contato,
      limite_atletas: event.limite_atletas
    )
  end

  def persisted?
    id.present?
  end

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      persist_event
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    promote_errors(e.record.errors)
    false
  end

  private

  def event
    @event ||= id.present? ? Event.find(id) : Event.new
  end

  def persist_event
    event.assign_attributes(
      nome: nome,
      descricao: descricao,
      cidade: cidade,
      estado: estado,
      local_partida: local_partida,
      data_largada: data_largada,
      horario_largada: horario_largada,
      slug_url: slug_url.parameterize,
      status: status,
      organizer_id: organizer_id,

      kit_descricao: kit_descricao,
      cronograma: cronograma,
      instagram_url: instagram_url,
      whatsapp_contato: whatsapp_contato,
      limite_atletas: limite_atletas
    )

    event.save!

    attach_files

    @id = event.id
  end

  def attach_files
    if banner.present?
      event.banner.attach(banner)
    end

    if regulamento.present?
      event.regulamento.attach(regulamento)
    end
  end

  def promote_errors(model_errors)
    model_errors.each do |error|
      errors.add(error.attribute, error.message)
    end
  end
end