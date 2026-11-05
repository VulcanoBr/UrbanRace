require "rails_helper"

RSpec.describe Waypoint, type: :model do
  describe "#aberto?" do
    it "retorna true quando não está fechado" do
      waypoint = build(:waypoint, closed_at: nil)

      expect(waypoint).to be_aberto
    end

    it "retorna false quando possui closed_at" do
      waypoint = build(:waypoint, closed_at: Time.current)

      expect(waypoint).not_to be_aberto
    end
  end

  describe "scopes" do
    it "retorna apenas pontos abertos" do
      aberto = create(:waypoint, closed_at: nil)
      fechado = create(:waypoint, closed_at: Time.current)

      expect(described_class.abertos).to include(aberto)
      expect(described_class.abertos).not_to include(fechado)
    end

    it "retorna apenas pontos fechados" do
      aberto = create(:waypoint, closed_at: nil)
      fechado = create(:waypoint, closed_at: Time.current)

      expect(described_class.fechados).to include(fechado)
      expect(described_class.fechados).not_to include(aberto)
    end

    it "retorna apenas o ponto de chegada" do
      chegada = create(:waypoint, eh_chegada: true)
      intermediario = create(:waypoint, eh_chegada: false)

      expect(described_class.chegada).to include(chegada)
      expect(described_class.chegada).not_to include(intermediario)
    end
  end
end