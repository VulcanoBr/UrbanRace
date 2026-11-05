# frozen_string_literal: true

require "rails_helper"

RSpec.describe AuthMailer, type: :mailer do
  describe "#password_reset" do
    let(:athlete) { create(:athlete) }
    let(:token) { "token123" }
    let(:mail) { described_class.with(user: athlete, token: token).password_reset }

    it "envia para o e-mail do usuário com o assunto correto" do
      expect(mail.to).to include(athlete.email_address)
      expect(mail.subject).to eq("Redefinição de senha - UrbanRace")
      expect(mail.body.encoded).to include(token)
    end
  end
end
