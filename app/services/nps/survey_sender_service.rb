# app/services/nps/survey_sender_service.rb
class Nps::SurveySenderService
  def self.schedule_for_event(event)
    # Busca todos os atletas que cruzaram a linha de chegada
    event.results.homologados.find_each do |result|
      # Agenda o envio para 24 horas a partir de agora via Solid Queue
      Nps::SendSurveyEmailJob.set(wait: 24.hours).perform_later(result.id)
    end
  end
end