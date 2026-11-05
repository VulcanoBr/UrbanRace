class Operation::IncidentForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :event_id, :integer
  attribute :dorsal, :integer
  attribute :tipo, :string
  attribute :gravidade, :string
  attribute :km_local, :decimal
  attribute :descricao, :string
  attribute :organizer_id, :integer

  attr_reader :incident

  validates :event_id, :tipo, :gravidade, :km_local, :descricao, presence: true
  
  # Nova validação: Se digitar um dorsal, ele deve existir
  validate :atleta_deve_existir_se_dorsal_presente

  def save
    return false unless valid?

    # Busca a inscrição
    registration = find_registration

    result = Operation::IncidentReportingService.call(
      event_id: event_id,
      registration_id: registration&.id, # Aqui pode ser nulo se não houver dorsal
      tipo: tipo,
      gravidade: gravidade,
      km_local: km_local,
      descricao: descricao,
      organizer_id: organizer_id
    )

    if result[:success]
      @emergency_info = result[:emergency_info]
      @incident = result[:incident]
      true
    else
      promote_errors(result[:errors])
      false
    end
  end

  attr_reader :emergency_info

  private

  def find_registration
    return nil if dorsal.blank?
    Registration.find_by(event_id: event_id, numero_dorsal: dorsal)
  end

  def atleta_deve_existir_se_dorsal_presente
    if dorsal.present? && find_registration.nil?
      errors.add(:dorsal, "não encontrado neste evento. Verifique o número.")
    end
  end

  def promote_errors(model_errors)
    model_errors.each { |e| errors.add(e.attribute, e.message) }
  end
end