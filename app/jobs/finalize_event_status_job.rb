# app/jobs/finalize_event_status_job.rb

class FinalizeEventStatusJob < ApplicationJob
  queue_as :default

  def perform
    # Marca como "finished" eventos com status "active" cuja data de largada já passou
    Event.where(status: "active")
         .where("data_largada < ?", Date.current)
         .find_each do |event|
      event.update!(status: "finished")
      Rails.logger.info "[FinalizeEventStatusJob] Evento ##{event.id} (#{event.slug_url}) finalizado."
    end
  end
end