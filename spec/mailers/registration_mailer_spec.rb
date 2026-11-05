# frozen_string_literal: true

require "rails_helper"

RSpec.describe RegistrationMailer, type: :mailer do
  describe "#confirmation_email" do
    let(:event) { create(:event, nome: "Meia Maratona") }
    let(:athlete) { create(:athlete) }
    let(:registration) { create(:registration, event: event, athlete: athlete, numero_dorsal: 101) }
    let(:mail) { described_class.with(registration: registration).confirmation_email }

    it "envia confirmação para o atleta" do
      expect(mail.to).to include(athlete.email_address)
      expect(mail.subject).to include("Inscrição Confirmada!")
      expect(mail.subject).to include("Dorsal #101")
    end
  end
end
