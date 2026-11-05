require "rails_helper"

RSpec.describe LicenseAlertJob, type: :job do
  let(:organizer) { create(:organizer) }
  let(:event)     { create(:event, organizer: organizer, status: "published") }

  describe "#perform" do
    let!(:vencendo) { create(:license, :expiring_soon, event: event) }
    let!(:ok)       { create(:license, :approved,      event: event) }
    let!(:expirada) { create(:license, :expired,       event: event) }

    it "enfileira no queue correto" do
      expect(described_class.queue_name).to eq("default")
    end

    it "dispara mailer para licenças em alerta" do
      mailer_double = double("mailer", deliver_later: true)
      allow(OrganizerMailer).to receive(:license_alert).and_return(mailer_double)

      described_class.perform_now

      expect(OrganizerMailer).to have_received(:license_alert).at_least(:once)
    end

    it "não dispara mailer para licenças aprovadas e fora da janela" do
      mailer_double = double("mailer", deliver_later: true)
      allow(OrganizerMailer).to receive(:license_alert).and_return(mailer_double)

      described_class.perform_now

      # Só :vencendo tem prazo em 7 dias e status pending → exatamente 1 chamada
      expect(OrganizerMailer).to have_received(:license_alert).once
    end

    it "pode ser enfileirado" do
      expect { described_class.perform_later }.to have_enqueued_job(described_class)
    end
  end
end