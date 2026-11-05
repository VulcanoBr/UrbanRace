# frozen_string_literal: true

require "rails_helper"

RSpec.describe Payment, type: :model do
  describe "validações" do
    it { is_expected.to validate_presence_of(:registration) }
    it { is_expected.to validate_presence_of(:metodo) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:valor) }

    it "exige pago_em quando status for pago" do
      payment = build(:payment, status: "pago", pago_em: nil)
      expect(payment).not_to be_valid
      expect(payment.errors[:pago_em]).to include("deve ser informado quando o pagamento estiver pago")
    end

    it "exige vencimento para pagamento via boleto" do
      payment = build(:payment, metodo: "boleto", vencimento: nil)
      expect(payment).not_to be_valid
      expect(payment.errors[:vencimento]).to include("deve ser informado para pagamentos via boleto")
    end

    it "não permite pago_em no futuro" do
      payment = build(:payment, status: "pago", pago_em: 1.day.from_now)
      expect(payment).not_to be_valid
      expect(payment.errors[:pago_em]).to include("não pode estar no futuro")
    end
  end

  describe "métodos de alteração de estado" do
    let(:payment) { create(:payment, status: "pendente") }

    it "marcar_como_pago! atualiza status e pago_em" do
      payment.marcar_como_pago!
      expect(payment).to be_pago
      expect(payment.pago_em).to be_present
    end

    it "cancelar! cancela pagamento pendente" do
      expect(payment.cancelar!).to be true
      expect(payment).to be_cancelado
    end

    it "estornar! estorna pagamento pago" do
      paid_payment = create(:payment, :pago)
      expect(paid_payment.estornar!).to be true
      expect(paid_payment).to be_estornado
    end

    it "estornar! retorna false se o pagamento não estiver pago" do
      expect(payment.estornar!).to be false
    end
  end

  describe "#vencido?" do
    it "retorna true se for pendente e vencimento estiver no passado" do
      payment = build(:payment, status: "pendente", vencimento: 1.day.ago)
      expect(payment).to be_vencido
    end

    it "retorna false se não estiver pendente ou vencimento no futuro" do
      payment = build(:payment, status: "pendente", vencimento: 1.day.from_now)
      expect(payment).not_to be_vencido
    end
  end
end