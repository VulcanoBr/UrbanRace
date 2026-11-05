# frozen_string_literal: true

class BatchCertificateJob < ApplicationJob
  queue_as :background

  def perform(event_id)
    event = Event.find(event_id)

    event.results
         .homologados
         .find_each(batch_size: 100) do |result|

      next if result.certificate&.gerado?

      Certificates::GenerateSingleJob.perform_later(result.id)
    end
  end
end