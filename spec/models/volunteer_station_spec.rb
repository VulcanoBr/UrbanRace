require "rails_helper"

RSpec.describe VolunteerStation, type: :model do
  describe "validações" do
    it "é válido com atributos obrigatórios" do
      expect(build(:volunteer_station)).to be_valid
    end

    it "exige nome" do
      station = build(:volunteer_station, nome: nil)

      expect(station).not_to be_valid
    end

    it "exige posição em quilômetros" do
      station = build(:volunteer_station, km_posicao: nil)

      expect(station).not_to be_valid
    end
  end
end