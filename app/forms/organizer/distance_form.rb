class Organizer::DistanceForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer
  attribute :event_id, :integer

  attribute :nome, :string
  attribute :km, :decimal

  attribute :vagas_total, :integer

  validates :event_id,
            :nome,
            :km,
            :vagas_total,
            presence: true

  validates :km,
            numericality: {
              greater_than: 0
            }

  validates :vagas_total,
            numericality: {
              greater_than: 0
            }

  def persisted?
    id.present?
  end

  def self.from_model(distance)
    new(
      id: distance.id,
      event_id: distance.event_id,
      nome: distance.nome,
      km: distance.km,
      vagas_total: distance.vagas_total
    )
  end

  def save
    return false unless valid?

    distance =
      id.present? ? Distance.find(id) : Distance.new

    distance.assign_attributes(
      event_id: event_id,
      nome: nome,
      km: km,
      vagas_total: vagas_total
    )

    if distance.save
      @id = distance.id
      true
    else
      promote_errors(distance.errors)
      false
    end
  end

  private

  def promote_errors(model_errors)
    model_errors.each do |error|
      errors.add(
        error.attribute,
        error.message
      )
    end
  end
end