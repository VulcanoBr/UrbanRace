# frozen_string_literal: true

require "rails_helper"

RSpec.describe SupplierDelivery, type: :model do
  describe "validações" do
    it { is_expected.to validate_presence_of(:descricao) }
    it { is_expected.to validate_presence_of(:data_prevista) }
    it { is_expected.to validate_presence_of(:status) }

    it "exige data_real quando a entrega estiver concluída" do
      delivery = build(:supplier_delivery, status: "completed", data_real: nil)
      expect(delivery).not_to be_valid
      expect(delivery.errors[:data_real]).to include("deve ser informada quando a entrega estiver concluída")
    end

    it "exige que data_real esteja ausente quando não estiver concluída" do
      delivery = build(:supplier_delivery, status: "pending", data_real: Date.current)
      expect(delivery).not_to be_valid
      expect(delivery.errors[:data_real]).to include("só pode ser informada quando a entrega estiver concluída")
    end
  end

  describe "#overdue?" do
    it "retorna true para entregas pendentes com data_prevista no passado" do
      delivery = build(:supplier_delivery, status: "pending", data_prevista: 2.days.ago.to_date)
      expect(delivery).to be_overdue
    end

    it "retorna false para entregas concluídas mesmo se a data prevista passou" do
      delivery = build(:supplier_delivery, :concluida, data_prevista: 2.days.ago.to_date)
      expect(delivery).not_to be_overdue
    end
  end

  describe "#situation" do
    it "retorna :overdue quando atrasada" do
      delivery = build(:supplier_delivery, :atrasada)
      expect(delivery.situation).to eq(:overdue)
    end

    it "retorna :completed quando concluída" do
      delivery = build(:supplier_delivery, :concluida)
      expect(delivery.situation).to eq(:completed)
    end
  end
end