# app/services/nps/action_service.rb
class Nps::ActionService
  def self.process(nps_response)
    case nps_response.nota_geral
    when 9..10
      # Promotor: Enviar cupom de desconto para a próxima prova
      coupon = Coupon.create_referral_for(nps_response.athlete)
      NpsMailer.thank_promoter(nps_response.athlete, coupon).deliver_now
    when 0..6
      # Detrator: Criar ocorrência administrativa para o organizador ligar
      Incident.create!(
        event: nps_response.event,
        tipo: "reclamacao_nps",
        gravidade: "alta",
        descricao: "Feedback Negativo NPS: #{nps_response.comentario}",
        responsavel: nps_response.event.organizer,
        status: "open"
      )
    end
  end
end