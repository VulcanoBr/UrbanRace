# spec/jobs/kit_pickup_reminder_scheduler_job_spec.rb
require "rails_helper"

RSpec.describe KitPickupReminderSchedulerJob, type: :job do
  include ActiveJob::TestHelper

  describe "#perform" do
    let!(:event_48h) { create(:event, data_largada: 48.hours.from_now) }
    let!(:event_24h) { create(:event, data_largada: 24.hours.from_now) }
    let!(:event_72h) { create(:event, data_largada: 72.hours.from_now) }

    let!(:reg_48h)   { create(:registration, :confirmado, event: event_48h) }
    let!(:reg_24h)   { create(:registration, :confirmado, event: event_24h) }
    let!(:reg_72h)   { create(:registration, :confirmado, event: event_72h) }

    it "enfileira KitPickupReminderJob apenas para os eventos nas janelas corretas" do
      expect {
        described_class.perform_now
      }.to have_enqueued_job(KitPickupReminderJob)
        .with(reg_48h.id, "48h")
        .and have_enqueued_job(KitPickupReminderJob)
        .with(reg_24h.id, "24h")
    end

    it "não enfileira para evento fora das janelas (72h)" do
      described_class.perform_now
      expect(enqueued_jobs.map { |j| j["arguments"] })
        .not_to include([reg_72h.id, anything])
    end

    context "quando atleta já fez checkin" do
      before { create(:athlete_checkin, registration: reg_48h) }

      it "não enfileira para esse atleta" do
        described_class.perform_now
        expect(enqueued_jobs.map { |j| j["arguments"] })
          .not_to include([reg_48h.id, "48h"])
      end
    end
  end
end
