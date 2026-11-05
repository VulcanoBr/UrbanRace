# app/forms/operation/closing_form.rb
class Operation::ClosingForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :waypoint_id, :integer
  attribute :organizer_id, :integer
  attribute :confirmacao_ultimo_atleta, :boolean

  validates :waypoint_id, :organizer_id, presence: true
  validates :confirmacao_ultimo_atleta, acceptance: { message: 'deve ser confirmada visualmente' }

  def save
    return false unless valid?
    Operation::CourseClosingService.close_point(waypoint_id, organizer_id)
  end
end