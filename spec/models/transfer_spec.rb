# frozen_string_literal: true

require "rails_helper"

RSpec.describe Transfer, type: :model do
  describe "validações" do
    it { is_expected.to validate_presence_of(:email_destino) }

    it do
      is_expected.to validate_inclusion_of(:status)
        .in_array(Transfer::STATUSES)
    end
  end

  describe "defaults" do
    it "define status como pendente ao criar" do
      transfer = build(
        :transfer,
        status: nil,
        solicitada_em: nil,
        taxa: nil
      )

      transfer.valid?

      expect(transfer.status).to eq("pendente")
      expect(transfer.solicitada_em).to be_present
      expect(transfer.taxa).to eq(0)
    end
  end

  describe "defaults" do
    it "define os valores padrão antes da validação" do
      transfer = build(
        :transfer,
        status: nil,
        solicitada_em: nil,
        taxa: nil
      )

      transfer.valid?

      expect(transfer.status).to eq("pendente")
      expect(transfer.solicitada_em).to be_present
      expect(transfer.taxa).to eq(0)
    end
  end

  describe "callbacks de token e expiração" do
    it "gera token e expiração de 48h ao criar" do
      transfer = build(
        :transfer,
        token: nil,
        token_expira_em: nil
      )

      transfer.valid?

      expect(transfer.token).to be_present
      expect(transfer.token_expira_em)
        .to be_within(1.minute)
        .of(48.hours.from_now)
    end
  end

  describe "#token_expirado?" do
    it "retorna true se token_expira_em estiver no passado" do
      transfer = build(:transfer, token_expira_em: 1.hour.ago)

      expect(transfer).to be_token_expirado
    end

    it "retorna false se token_expira_em estiver no futuro" do
      transfer = build(:transfer, token_expira_em: 2.hours.from_now)

      expect(transfer).not_to be_token_expirado
    end
  end
  
end