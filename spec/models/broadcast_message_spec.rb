require "rails_helper"

RSpec.describe BroadcastMessage, type: :model do
  subject(:broadcast) { build(:broadcast_message) }

  describe "validações" do
    it "é válido com atributos obrigatórios" do
      expect(broadcast).to be_valid
    end

    it "exige título" do
      broadcast.titulo = nil

      expect(broadcast).not_to be_valid
      expect(broadcast.errors[:titulo]).to be_present
    end

    it "exige corpo" do
      broadcast.corpo = nil

      expect(broadcast).not_to be_valid
      expect(broadcast.errors[:corpo]).to be_present
    end

    it "exige categoria" do
      broadcast.categoria = nil

      expect(broadcast).not_to be_valid
      expect(broadcast.errors[:categoria]).to be_present
    end
  end

  describe "categoria" do
    it "usa informativo como padrão" do
      expect(build(:broadcast_message).categoria).to eq("informativo")
    end

    it "identifica mensagem crítica" do
      broadcast = build(:broadcast_message, categoria: :urgente)

      expect(broadcast).to be_critical
    end

    it "não considera mensagem informativa como crítica" do
      broadcast = build(:broadcast_message, categoria: :informativo)

      expect(broadcast).not_to be_critical
    end
  end
end