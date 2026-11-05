class Organizer::DashboardsController < Organizer::BaseController

  layout "admin"

  def show
    @events = current_organizer.events.order(data_largada: :asc)
    @upcoming_events = @events.where("data_largada >= ?", Date.current)
                              .where.not(status: %w[cancelled finished])
                              .limit(3)
    
    # CONSULTA CORRIGIDA: Selecionamos apenas os nomes e a contagem.
    # Isso evita que o Rails tente carregar IDs que quebrariam o GROUP BY do Postgres.
    @waitlist_by_distance = Waitlist.aguardando
                                    .joins(:event, :distance)
                                    .where.not(events: { status: [:finished, :cancelled] })
                                    .select("events.nome AS event_name, distances.nome AS distance_name, COUNT(waitlists.id) AS total")
                                    .group("events.id, events.nome, distances.id, distances.nome")
                                    .order("total DESC")

    # Métricas Globais
    @global_stats = {
      total_atletas: Athlete.count,
      total_inscricoes: Registration.confirmado.count,
      faturamento_total: Payment.where(status: :pago).sum(:valor) || 0,
      licencas_pendentes: License.where(status: [:pending, :requested]).count,
      vagas_totais: Distance.sum(:vagas_total) || 0,
      vagas_preenchidas: Distance.sum(:vagas_ocupadas) || 0,
      total_waitlist: Waitlist.aguardando.joins(:event).where.not(events: { status: :finished }).count
    }

    @recent_registrations = Registration.confirmado
                                    .joins(:event)
                                    .where(events: { status: "published" })
                                    .includes(:athlete, :event)
                                    .order(created_at: :desc)
                                    .limit(5)
  end

end