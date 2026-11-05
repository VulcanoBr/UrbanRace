class LicenseAlertJob < ApplicationJob
  queue_as :default

  # Recebe um event_id opcional. Sem argumento, percorre todos os eventos ativos.
  def perform(event_id: nil)
    events = event_id ? Event.where(id: event_id) : Event.where(status: %w[published active])

    events.find_each do |event|
      check_licenses_for(event)
    end
  end

  private

  def check_licenses_for(event)
    # Licenças com prazo de aprovação nos próximos 30 dias e ainda não aprovadas
    at_risk = event.licenses.where(
      status: %w[pending],           # ← era %w[pending in_review]; "in_review" não existe no enum
    ).where(
      "prazo_aprovacao BETWEEN ? AND ?", Date.current, 30.days.from_now
    )

    return if at_risk.none?

    at_risk.each do |license|
      days_remaining = (license.prazo_aprovacao - Date.current).to_i

      # Só alerta nos marcos: 30, 15 e 7 dias (OR-14)
      next unless days_remaining.in?([30, 15, 7])

      # Evita spam: verifica se já enviou alerta hoje para esta licença
      next if alerted_today?(license)

      notify_organizers(event, license, days_remaining)
    end
  end

  def notify_organizers(event, license, days_remaining)
    # Notifica o dono do evento e todos os organizadores associados
    recipients = event_organizers(event)

    recipients.each do |organizer|
      OrganizerMailer.license_alert(
        organizer: organizer,
        event:     event,
        license:   license,
        days:      days_remaining
      ).deliver_later
    end

    Rails.logger.info(
      "[LicenseAlertJob] Alerta enviado — evento=#{event.slug_url} " \
      "licenca=#{license.id} dias=#{days_remaining}"
    )
  end

  def event_organizers(event)
    # Adapte conforme sua estrutura: dono + admins do evento
    [event.organizer].compact
  end

  def alerted_today?(license)
    # Guarda um flag no cache para não duplicar o alerta no mesmo dia
    cache_key = "license_alert_sent:#{license.id}:#{Date.current}"
    return true if Rails.cache.exist?(cache_key)

    Rails.cache.write(cache_key, true, expires_in: 25.hours)
    false
  end
end