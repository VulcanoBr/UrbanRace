class Organizer::CategoryForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :id, :integer
  attribute :distance_id, :integer
  attribute :nome, :string
  attribute :sexo, :string
  attribute :idade_min, :integer
  attribute :idade_max, :integer

  # 1. Correção da validação: greater_than com Proc
  validates :nome, :sexo, :idade_min, :idade_max, :distance_id, presence: true
  validates :idade_min, numericality: { greater_than_or_equal_to: 0 }
  validates :idade_max, numericality: { greater_than: ->(form) { form.idade_min.to_i } }, if: -> { idade_min.present? }
  validates :sexo, inclusion: { in: Category.sexos.keys }

  # 2. Adicionar este método para o form_with saber que é uma edição
  def persisted?
    id.present?
  end

  def self.from_model(category)
    new(
      id: category.id,
      distance_id: category.distance_id,
      nome: category.nome,
      sexo: category.sexo,
      idade_min: category.idade_min,
      idade_max: category.idade_max
    )
  end

  def save
    return false unless valid?

    category = id.present? ? Category.find(id) : Category.new
    category.assign_attributes(
      distance_id: distance_id,
      nome: nome,
      sexo: sexo,
      idade_min: idade_min,
      idade_max: idade_max
    )

    if category.save
      @id = category.id
      true
    else
      promote_errors(category.errors)
      false
    end
  end

  private

  def promote_errors(model_errors)
    model_errors.each { |e| errors.add(e.attribute, e.message) }
  end
end