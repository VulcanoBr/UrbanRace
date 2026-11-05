# app/services/organizer/license_status_service.rb
class Organizer::LicenseStatusService
  DEFAULT_ALERT_DAYS = 7

  def initialize(event)
    @event = event
  end

  # Chamado pelo spec: check_all → { expiring_soon:, expired:, total_alerts: }
  def check_all
    licenses = @event.licenses.where.not(status: "approved")

    expiring_soon = licenses.select { |l| expirando_em_breve?(l) && !vencida?(l) }
    expired       = licenses.select { |l| vencida?(l) }

    {
      expiring_soon:  expiring_soon,
      expired:        expired,
      total_alerts:   (expiring_soon + expired).uniq.size
    }
  end

  # Chamado pelo spec: needs_alert?(license) → true/false
  def needs_alert?(license, dias: DEFAULT_ALERT_DAYS)
    return true if vencida?(license)
    return true if expirando_em_breve?(license, dias: dias)
    false
  end

  # Mantém compatibilidade com o painel existente
  def health_report
    resultado = check_all
    {
      total:        @event.licenses.count,
      pendentes:    @event.licenses.where(status: "pending").count,
      vencidas:     resultado[:expired].size,
      status_geral: determine_overall_status
    }
  end

  private

  def vencida?(license)
    license.status.to_s == "expired" ||
      (license.prazo_aprovacao.present? && license.prazo_aprovacao < Date.current)
  end

  def expirando_em_breve?(license, dias: DEFAULT_ALERT_DAYS)
    return false if license.status.to_s == "approved"
    return false unless license.prazo_aprovacao.present?

    license.prazo_aprovacao <= dias.days.from_now.to_date &&
      license.prazo_aprovacao >= Date.current
  end

  def determine_overall_status
    return "danger"  if @event.licenses.where("prazo_aprovacao < ?", Date.current).exists?
    return "warning" if @event.licenses.where(status: "pending").exists?
    "success"
  end
end