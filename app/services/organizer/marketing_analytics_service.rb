# app/services/organizer/marketing_analytics_service.rb
class Organizer::MarketingAnalyticsService
  def initialize(event)
    @event = event
  end

  def funnel_data
    total_cliques = @event.sponsors.sum(:inscricoes_geradas) * 5 # Estimativa baseada em CTR
    inscricoes = @event.registrations.count
    pagos = @event.registrations.confirmado.count

    {
      taxa_conversao: (inscricoes.to_f / total_cliques * 100).round(2),
      taxa_pagamento: (pagos.to_f / inscricoes * 100).round(2),
      custo_por_inscrito: calcular_cpa
    }
  end

  private
  def calcular_cpa
    investimento = @event.email_campaigns.count * 10 # Custo fixo fictício por campanha
    return 0 if @event.registrations.count == 0
    (investimento.to_f / @event.registrations.count).round(2)
  end
end