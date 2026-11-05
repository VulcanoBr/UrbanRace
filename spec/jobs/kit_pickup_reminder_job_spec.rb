# spec/jobs/kit_pickup_reminder_job_spec.rb
require "rails_helper"

RSpec.describe KitPickupReminderJob, type: :job do
  include ActiveJob::TestHelper

  let(:event)        { create(:event, data_largada: 30.hours.from_now) }
  let(:registration) { create(:registration, :confirmado, event: event) }

  describe "#perform" do
    context "quando a inscrição está confirmada e sem checkin" do
      it "enfileira o mailer" do
        expect {
          described_class.perform_now(registration.id, "48h")
        }.to have_enqueued_mail(RegistrationsMailer, :kit_pickup_reminder)
      end
    end

    context "quando a inscrição foi cancelada" do
      before { registration.update!(status: "cancelled") }

      it "não enfileira o mailer" do
        expect {
          described_class.perform_now(registration.id, "48h")
        }.not_to have_enqueued_mail(RegistrationsMailer, :kit_pickup_reminder)
      end
    end

    context "quando o atleta já fez checkin" do
      before { create(:athlete_checkin, registration: registration) }

      it "não enfileira o mailer" do
        expect {
          described_class.perform_now(registration.id, "48h")
        }.not_to have_enqueued_mail(RegistrationsMailer, :kit_pickup_reminder)
      end
    end

    context "quando a largada já passou" do
      let(:event) { create(:event, data_largada: 1.hour.ago) }

      it "não enfileira o mailer" do
        expect {
          described_class.perform_now(registration.id, "48h")
        }.not_to have_enqueued_mail(RegistrationsMailer, :kit_pickup_reminder)
      end
    end

    context "quando o registration_id não existe" do
      it "não levanta erro" do
        expect {
          described_class.perform_now(0, "48h")
        }.not_to raise_error
      end
    end
  end
end
