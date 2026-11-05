# frozen_string_literal: true

require "rails_helper"

RSpec.describe SupplierContract, type: :model do
  describe "validações" do
    it { is_expected.to validate_presence_of(:supplier) }
    it { is_expected.to validate_presence_of(:event) }
    it { is_expected.to validate_presence_of(:valor) }
    it { is_expected.to validate_presence_of(:status) }

    it "exige assinado_em quando status for assinado" do
      contract = build(:supplier_contract, status: "signed", assinado_em: nil)
      expect(contract).not_to be_valid
      expect(contract.errors[:assinado_em]).to include("não pode ficar em branco")
    end

    it "não permite assinado_em em data futura" do
      contract = build(:supplier_contract, status: "signed", assinado_em: 2.days.from_now.to_date)
      expect(contract).not_to be_valid
      expect(contract.errors[:assinado_em]).to include("não pode ser uma data futura")
    end
  end
end