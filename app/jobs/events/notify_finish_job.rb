# app/jobs/events/notify_finish_job.rb
#
# Notifica atletas confirmados quando o evento é finalizado.
# Disparado por event.finish!
#
module Events
  class NotifyFinishJob < ApplicationJob
    queue_as :default

    retry_on StandardError, wait: 10.seconds, attempts: 3

    def perform(event_id)
      event = Event.find(event_id)

      event.registrations
           .where(status: %w[confirmed checked_in])
           .includes(:athlete)
           .find_each do |registration|
        EventMailer.event_finished(
          event:        event,
          registration: registration
        ).deliver_later
      end
    end
  end
end
