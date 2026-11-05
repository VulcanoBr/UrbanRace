require "rails_helper"

RSpec.describe Incident, type: :model do
  subject(:incident) { build(:incident) }

  describe "validações" do
    it "é válido com atributos obrigatórios" do
      expect(incident).to be_valid
    end

    it "exige tipo" do
      incident.tipo = nil

      expect(incident).not_to be_valid
    end

    it "exige gravidade" do
      incident.gravidade = nil

      expect(incident).not_to be_valid
    end

    it "exige localização em quilômetros" do
      incident.km_local = nil

      expect(incident).not_to be_valid
    end
  end

  describe "defaults" do
    it "define ocorrida_em automaticamente" do
      incident = build(:incident, ocorrida_em: nil)

      incident.valid?

      expect(incident.ocorrida_em).to be_present
    end

    it "usa aberto como status padrão" do
      expect(build(:incident).status).to eq("aberto")
    end
  end
end