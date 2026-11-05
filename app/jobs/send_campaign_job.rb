# app/jobs/send_campaign_job.rb
class SendCampaignJob < ApplicationJob
  queue_as :background

  def perform(campaign_id, conteudo)
    campaign = EmailCampaign.find(campaign_id)
    event = campaign.event
    
    # Busca os destinatários usando o Service
    targets = Organizer::CampaignTargetService.new(event, campaign.segmento).emails
    
    targets.each do |email|
      # Dispara cada e-mail individualmente para evitar SPAM e permitir rastreio futuro
      CampaignMailer.send_batch(email, campaign.assunto, conteudo).deliver_later
    end

    # Atualiza a campanha como finalizada
    campaign.update!(
      enviados: targets.size,
      enviado_em: Time.current
    )
  end
end