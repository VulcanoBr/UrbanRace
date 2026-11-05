# frozen_string_literal: true

require "rails_helper"

RSpec.describe PendingTransfer, type: :model do
  describe "validações" do
    it { is_expected.to validate_presence_of(:email_destino) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:expira_em) }
    it { is_expected.to validate_inclusion_of(:status).in_array(PendingTransfer::STATUSES) }
  end

  describe "métodos de estado" do
    it "#expirou? retorna true quando expira_em <= agora" do
      pending = build(:pending_transfer, expira_em: Time.current)
      expect(pending).to be_expirou
    end

    it "#pendente? retorna true apenas quando aguardando e não expirado" do
      pending = build(:pending_transfer, status: "aguardando", expira_em: 1.hour.from_now)
      expect(pending).to be_pendente
    end
  end

  describe "token de aceitação" do
    it "gera token via generates_token_for :acceptance" do
      pending = create(:pending_transfer)
      token = pending.generate_token_for(:acceptance)
      expect(token).to be_present
    end
  end
end