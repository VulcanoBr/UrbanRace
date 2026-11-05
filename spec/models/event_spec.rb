# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event, type: :model do
  describe "validações" do
    it { is_expected.to validate_presence_of(:nome) }
    it { is_expected.to validate_presence_of(:data_largada) }
    it { is_expected.to validate_presence_of(:slug_url) }
    it { is_expected.to validate_presence_of(:cidade) }
    it { is_expected.to validate_presence_of(:estado) }
    it { is_expected.to validate_presence_of(:local_partida) }
    it { is_expected.to validate_presence_of(:horario_largada) }
    it { is_expected.to validate_presence_of(:limite_atletas) }
  end

  describe "#full_address" do
    it "combina local, cidade e estado" do
      event = build(:event, local_partida: "Parque Aterro", cidade: "Rio de Janeiro", estado: "RJ")
      expect(event.full_address).to eq("Parque Aterro - Rio de Janeiro/RJ")
    end
  end

  describe "#days_until_event" do
    it "calcula a diferença de dias até a largada" do
      event = build(:event, data_largada: 10.days.from_now.to_date)
      expect(event.days_until_event).to eq(10)
    end

    it "retorna 0 para eventos passados" do
      event = build(:event, data_largada: 5.days.ago.to_date)
      expect(event.days_until_event).to eq(0)
    end
  end

  describe "#to_param" do
    it "retorna a slug_url em vez do ID" do
      event = build(:event, slug_url: "maratona-urbana-2026")
      expect(event.to_param).to eq("maratona-urbana-2026")
    end
  end
end