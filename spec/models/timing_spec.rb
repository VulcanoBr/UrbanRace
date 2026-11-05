require "rails_helper"

RSpec.describe Timing, type: :model do
  describe "validações" do
    it "exige chip_time" do
      timing = build(:timing, chip_time: nil)

      expect(timing).not_to be_valid
    end
  end

  describe ".por_tempo" do
    it "ordena os registros pelo tempo do chip" do
      slower = create(:timing, chip_time: 10.minutes.from_now)
      faster = create(:timing, chip_time: 5.minutes.from_now)

      expect(described_class.por_tempo).to eq([faster, slower])
    end
  end
end