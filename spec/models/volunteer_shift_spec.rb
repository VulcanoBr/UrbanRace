require "rails_helper"

RSpec.describe VolunteerShift, type: :model do
  describe "turno" do
    it "exige turno" do
      shift = build(:volunteer_shift, turno: nil)

      expect(shift).not_to be_valid
    end

    it "aceita os turnos definidos" do
      expect(
        build(:volunteer_shift, turno: :manha)
      ).to be_valid

      expect(
        build(:volunteer_shift, turno: :tarde)
      ).to be_valid

      expect(
        build(:volunteer_shift, turno: :noite)
      ).to be_valid

      expect(
        build(:volunteer_shift, turno: :integral)
      ).to be_valid
    end
  end

  describe "status" do
    it "usa pendente como padrão" do
      expect(build(:volunteer_shift).status).to eq("pendente")
    end
  end
end