# app/services/athletes/portal_service.rb
class Athletes::PortalService
  def initialize(athlete)
    @athlete = athlete
  end

  def dashboard_data
    {
      # Usamos 'ativos_para_prova' para incluir tanto 'confirmado' quanto 'checado'
      proximas_provas: @athlete.registrations.ativos_para_prova
                               .joins(:event)
                               .where("events.data_largada >= ?", Date.today)
                               .order("events.data_largada ASC"),

      provas_passadas: @athlete.registrations.ativos_para_prova
                               .joins(:event)
                               .where("events.data_largada < ?", Date.today)
                               .order("events.data_largada DESC"),

      inscricoes_pendentes: @athlete.registrations.pendente.limit(3)
    }
  end
end