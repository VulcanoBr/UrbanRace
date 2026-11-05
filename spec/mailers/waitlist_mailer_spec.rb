# frozen_string_literal: true

require "rails_helper"

RSpec.describe WaitlistMailer, type: :mailer do
  let(:event) { create(:event, nome: "Urban Run") }
  let(:athlete) { create(:athlete) }
  let(:waitlist) { create(:waitlist, event: event, athlete: athlete, posicao: 3) }

  describe "#entrada_confirmada" do
    let(:mail) { described_class.entrada_confirmada(waitlist) }

    it "informa a posição na lista de espera" do
      expect(mail.to).to include(athlete.email_address)
      expect(mail.subject).to include("posição 3")
    end
  end

  describe "#vaga_disponivel" do
    let(:mail) { described_class.vaga_disponivel(waitlist) }

    it "notifica que uma vaga abriu" do
      expect(mail.to).to include(athlete.email_address)
      expect(mail.subject).to include("Uma vaga abriu para você!")
    end
  end
end
