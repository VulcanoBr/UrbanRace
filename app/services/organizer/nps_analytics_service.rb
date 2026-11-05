# app/services/organizer/nps_analytics_service.rb
class Organizer::NpsAnalyticsService
  def initialize(event)
    @responses = event.nps_responses.includes(:athlete)
  end

  def calculate_report
    return empty_report if @responses.none?

    total = @responses.count.to_f
    promoters = @responses.where(nota_geral: 9..10).count
    detractors = @responses.where(nota_geral: 0..6).count
    passives = @responses.where(nota_geral: 7..8).count

    # Cálculo oficial do NPS: % Promotores - % Detratores
    nps_score = (((promoters - detractors) / total) * 100).round(0)

    {
      score: nps_score,
      total_respostas: total.to_i,
      distribuicao: { promotores: promoters, passivos: passives, detratores: detractors },
      medias: {
        percurso: @responses.average(:nota_percurso).to_f.round(1),
        organizacao: @responses.average(:nota_organizacao).to_f.round(1),
        estrutura: @responses.average(:nota_estrutura).to_f.round(1),
        comunicacao: @responses.average(:nota_comunicacao).to_f.round(1)
      },
      comentarios: @responses.where.not(comentario: [nil, ""]).order(created_at: :desc)
    }
  end

  private

  def empty_report
    { score: 0, total_respostas: 0, medias: {}, distribuicao: {}, comentarios: [] }
  end
end