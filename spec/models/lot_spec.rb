# frozen_string_literal: true

require "rails_helper"

RSpec.describe Lot, type: :model do
  describe "validações" do
    it { is_expected.to validate_presence_of(:numero) }
    it { is_expected.to validate_presence_of(:preco) }
    it { is_expected.to validate_presence_of(:vagas) }
    it { is_expected.to validate_presence_of(:abertura) }
    it { is_expected.to validate_presence_of(:encerramento) }

    it "valida que encerramento é maior que abertura" do
      lot = build(:lot, abertura: Time.current, encerramento: 1.hour.ago)
      expect(lot).not_to be_valid
      expect(lot.errors[:encerramento]).to include("deve ser maior que a abertura")
    end
  end

  describe "#vagas_disponiveis" do
    let(:lot) { create(:lot, vagas: 100) }

    it "retorna total de vagas quando não há inscrições" do
      expect(lot.vagas_disponiveis).to eq(100)
    end

    it "nunca retorna valor negativo" do
      allow(lot).to receive(:vagas_ocupadas).and_return(120)
      expect(lot.vagas_disponiveis).to eq(0)
    end
  end

  describe "#disponivel?" do
    it "retorna true quando ativo e com vagas disponíveis" do
      lot = create(:lot, status: "active", vagas: 50)
      expect(lot).to be_disponivel
    end

    it "retorna false quando inativo" do
      lot = create(:lot, status: "inactive", vagas: 50)
      expect(lot).not_to be_disponivel
    end
  end

  describe "scopes" do
    it "atuais retorna apenas lotes com abertura <= agora <= encerramento e ativos" do
      vigente = create(:lot, :vigente)
      futuro = create(:lot, :futuro)

      expect(Lot.atuais).to include(vigente)
      expect(Lot.atuais).not_to include(futuro)
    end
  end
end