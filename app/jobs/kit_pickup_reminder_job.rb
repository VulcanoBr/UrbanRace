# app/jobs/kit_pickup_reminder_job.rb
#
# Enviado pelo KitPickupReminderSchedulerJob em dois momentos:
#   - 48 h antes da largada  (kind: "48h")
#   - 24 h antes da largada  (kind: "24h")
#
# Recebe registration_id + kind diretamente: é idempotente e pode ser
# reenfileirado sem risco de duplicar e-mails — o job valida o estado
# atual da inscrição antes de enviar.
class KitPickupReminderJob < ApplicationJob
  queue_as :default

  # Solid Queue: até 2 tentativas com back-off de 10 minutos
  retry_on StandardError, wait: 10.minutes, attempts: 2

  # @param registration_id [Integer]
  # @param kind [String] "48h" | "24h"
  def perform(registration_id, kind)
    registration = Registration
                     .includes(:athlete, :event, :distance, :athlete_checkins)
                     .find_by(id: registration_id)

    # Guard clauses — skip silencioso em todos os casos abaixo
    return unless registration
    return unless registration.confirmado?            # enum confirmado → "confirmed"
    return if registration.athlete_checkins.any?      # checkin já realizado
    return if registration.event.data_largada < Time.current # largada já passou

    RegistrationsMailer
      .with(registration: registration, kind: kind)
      .kit_pickup_reminder
      .deliver_later
  end
end
