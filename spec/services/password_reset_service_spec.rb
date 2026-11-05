# frozen_string_literal: true

require "rails_helper"

RSpec.describe PasswordResetService do
  let!(:athlete) { create(:athlete, email_address: "atleta@example.com") }

  describe ".send_instructions" do
    it "envia e-mail de redefinição para atleta cadastrado" do
      expect {
        described_class.send_instructions(email_address: "atleta@example.com", user_type: "athlete")
      }.to have_enqueued_mail(AuthMailer, :password_reset)
    end

    it "retorna true silenciosamente se o e-mail não existir" do
      expect {
        described_class.send_instructions(email_address: "inexistente@example.com", user_type: "athlete")
      }.not_to have_enqueued_mail(AuthMailer, :password_reset)
    end
  end
end
