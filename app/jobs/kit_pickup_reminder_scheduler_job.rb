# app/jobs/kit_pickup_reminder_scheduler_job.rb
#
# Roda diariamente (ver config/recurring.yml).
# Para cada evento que larga em ~48 h ou ~24 h a partir de agora,
# enfileira um KitPickupReminderJob por inscrição confirmada sem checkin.
#
# Janela de tolerância: +/- 30 minutos ao redor do horário exato.
# Isso garante que o scheduler diário (8 h da manhã) captura os eventos
# independentemente do horário da largada do dia correspondente.
class KitPickupReminderSchedulerJob < ApplicationJob
  queue_as :default

  TOLERANCE = 30.minutes
  WINDOWS   = {
    "48h" => 48.hours,
    "24h" => 24.hours
  }.freeze

  def perform
    WINDOWS.each do |kind, offset|
      target_start = offset.from_now - TOLERANCE
      target_end   = offset.from_now + TOLERANCE

      # Busca eventos que largam dentro da janela correspondente
      events = Event
                 .where(data_largada: target_start..target_end)
                 .where.not(status: :cancelled)   # ajuste ao nome do status cancelado no seu enum
                 .pluck(:id)

      next if events.empty?

      # Busca inscrições confirmadas sem checkin nesses eventos
      registrations_to_notify(events).find_each do |registration|
        KitPickupReminderJob
          .set(wait: jitter)   # pequeno jitter para não sobrecarregar o mailer
          .perform_later(registration.id, kind)
      end
    end
  end

  private

  def registrations_to_notify(event_ids)
    Registration
      .confirmado                             # scope do enum: confirmado → "confirmed"
      .where(event_id: event_ids)
      .left_outer_joins(:athlete_checkins)
      .where(athlete_checkins: { id: nil })   # sem checkin
      .includes(:athlete, :event)             # evita N+1 no job filho
  end

  # Distribui os envios ao longo de até 5 minutos para não estourar rate limits
  def jitter
    rand(0..300).seconds
  end
end
