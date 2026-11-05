require "rails_helper"

RSpec.describe SponsorContract, type: :model do
  describe "status" do
    it "possui os status esperados" do
      expect(described_class.statuses).to include(
        "negociacao" => "negotiating",
        "assinado"   => "signed",
        "concluido"  => "completed",
        "cancelado"  => "cancelled"
      )
    end

    it "aceita os status definidos" do
      expect(build(:sponsor_contract, status: :negociacao)).to be_valid
      expect(build(:sponsor_contract, status: :assinado)).to be_valid
      expect(build(:sponsor_contract, status: :concluido)).to be_valid
      expect(build(:sponsor_contract, status: :cancelado)).to be_valid
    end
  end
end