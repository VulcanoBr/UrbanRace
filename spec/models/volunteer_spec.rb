require "rails_helper"

RSpec.describe Volunteer, type: :model do
  describe "validações" do
    it "é válido com atributos obrigatórios" do
      expect(build(:volunteer)).to be_valid
    end

    it "exige nome" do
      expect(build(:volunteer, nome: nil)).not_to be_valid
    end

    it "exige email" do
      expect(build(:volunteer, email: nil)).not_to be_valid
    end

    it "exige telefone" do
      expect(build(:volunteer, telefone: nil)).not_to be_valid
    end

    it "não permite email duplicado" do
      volunteer = create(:volunteer)

      duplicate = build(:volunteer, email: volunteer.email)

      expect(duplicate).not_to be_valid
    end
  end
end