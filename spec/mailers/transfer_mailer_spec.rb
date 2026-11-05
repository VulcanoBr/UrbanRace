# frozen_string_literal: true

require "rails_helper"

RSpec.describe TransferMailer, type: :mailer do
  let(:event) { create(:event, nome: "Maratona do Rio") }
  let(:atleta) { create(:athlete) }
  let(:registration) { create(:registration, event: event) }

  describe "#transferencia_concluida_origem" do
    let(:mail) { described_class.transferencia_concluida_origem(atleta: atleta, registration: registration) }

    it "notifica a origem que a vaga foi transferida" do
      expect(mail.to).to include(atleta.email_address)
      expect(mail.subject).to include("Sua vaga foi transferida com sucesso")
    end
  end

  describe "#transferencia_concluida_destino" do
    let(:mail) { described_class.transferencia_concluida_destino(atleta: atleta, registration: registration) }

    it "notifica o destino que recebeu a vaga" do
      expect(mail.to).to include(atleta.email_address)
      expect(mail.subject).to include("Você recebeu uma vaga!")
    end
  end
end
