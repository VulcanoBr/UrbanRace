# app/services/operation/incident_reporting_service.rb
class Operation::IncidentReportingService
  def self.call(incident_params)
    incident = Incident.new(incident_params)
    incident.ocorrida_em ||= Time.current

    if incident.save
      # 1. Alerta em tempo real para o Organizador (Solid Cable)
      broadcast_to_dashboard(incident)

      # 2. Retorna informações de emergência se for um atleta cadastrado
      emergency_info = get_emergency_info(incident)
      
      return { success: true, incident: incident, emergency_info: emergency_info }
    end

    { success: false, errors: incident.errors }
  end

  private

  def self.broadcast_to_dashboard(incident)
    Turbo::StreamsChannel.broadcast_prepend_to(
      "event_#{incident.event_id}_incidents",
      target: "incidents_list",
      partial: "organizer/incidents/incident_row",
      locals: { incident: incident }
    )
  end

  def self.get_emergency_info(incident)
    return nil unless incident.registration_id.present?
    
    reg = incident.registration
    {
      contato: reg.contato_emergencia,
      telefone: reg.fone_emergencia,
      atleta: reg.athlete.nome
    }
  end
end