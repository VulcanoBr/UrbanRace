# frozen_string_literal: true

require "rails_helper"

RSpec.describe Coupon, type: :model do
  describe "validações" do
    it { is_expected.to validate_presence_of(:codigo) }
    it { is_expected.to validate_presence_of(:tipo) }
    it { is_expected.to validate_presence_of(:valor) }

    it "valida que valor percentual é <= 100" do
      coupon = build(:coupon, tipo: "percentual", valor: 105)
      expect(coupon).not_to be_valid
      expect(coupon.errors[:valor]).to include("deve ser menor ou igual a 100 para cupons percentuais")
    end

    it "valida que uso_atual não pode ser maior que uso_maximo" do
      coupon = build(:coupon, uso_maximo: 5, uso_atual: 6)
      expect(coupon).not_to be_valid
      expect(coupon.errors[:uso_atual]).to include("não pode ser maior que o uso máximo")
    end
  end

  describe "#valido?" do
    it "retorna true quando ativo, na validade e com uso disponível" do
      coupon = build(:coupon, validade: 1.day.from_now, uso_maximo: 10, uso_atual: 2)
      expect(coupon).to be_valido
    end

    it "retorna false quando expirado" do
      coupon = build(:coupon, :expirado)
      expect(coupon).not_to be_valido
    end

    it "retorna false quando esgotado" do
      coupon = build(:coupon, :esgotado)
      expect(coupon).not_to be_valido
    end
  end

  describe "#aplicavel_para?" do
    let(:event) { create(:event) }
    let(:distance) { create(:distance, event: event) }
    let(:category) { create(:category, distance: distance) }
    let(:coupon) { create(:coupon, event: event, distance: distance, category: category) }

    it "retorna true quando o evento, distância e categoria correspondem" do
      expect(coupon.aplicavel_para?(distance: distance, category: category)).to be true
    end

    it "retorna false se a distância for diferente" do
      other_distance = create(:distance, event: event)
      expect(coupon.aplicavel_para?(distance: other_distance, category: category)).to be false
    end
  end

  describe "#calcular_desconto" do
    context "cupom percentual" do
      let(:coupon) { create(:coupon, :percentual, valor: 10) }

      it "calcula desconto corretamente" do
        expect(coupon.calcular_desconto(100)).to eq(BigDecimal("10"))
      end
    end

    context "cupom fixo" do
      let(:coupon) { create(:coupon, :fixo, valor: 20) }

      it "calcula desconto corretamente" do
        expect(coupon.calcular_desconto(100)).to eq(BigDecimal("20"))
      end
    end

    it "não permite desconto maior que o valor original" do
      coupon = create(:coupon, :fixo, valor: 200)
      expect(coupon.calcular_desconto(100)).to eq(BigDecimal("100"))
    end
  end

  describe "#calcular_valor_final" do
    it "retorna o valor original menos o desconto" do
      coupon = create(:coupon, :fixo, valor: 30)
      expect(coupon.calcular_valor_final(100)).to eq(BigDecimal("70"))
    end
  end

  describe "#registrar_uso!" do
    let(:coupon) { create(:coupon, uso_maximo: 2, uso_atual: 0) }

    it "incrementa a utilização" do
      expect { coupon.registrar_uso! }.to change { coupon.reload.uso_atual }.from(0).to(1)
    end

    it "levanta CouponUnavailableError se o cupom estiver expirado" do
      expirado = create(:coupon, :expirado)
      expect { expirado.registrar_uso! }.to raise_error(Coupon::CouponUnavailableError, "Cupom expirado.")
    end

    it "levanta CouponUnavailableError se o cupom atingiu uso máximo" do
      esgotado = create(:coupon, :esgotado)
      expect { esgotado.registrar_uso! }.to raise_error(Coupon::CouponUnavailableError, "Cupom atingiu o limite máximo de utilizações.")
    end
  end

  describe "#status" do
    it "retorna :expirado quando o prazo venceu" do
      coupon = build(:coupon, :expirado)
      expect(coupon.status).to eq(:expirado)
    end

    it "retorna :esgotado quando não há vagas" do
      coupon = build(:coupon, :esgotado)
      expect(coupon.status).to eq(:esgotado)
    end

    it "retorna :disponivel quando válido" do
      coupon = build(:coupon)
      expect(coupon.status).to eq(:disponivel)
    end
  end
end