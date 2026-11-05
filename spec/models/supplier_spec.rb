require "rails_helper"

RSpec.describe Supplier, type: :model do
  describe "validações" do
    it "é válido com atributos obrigatórios" do
      expect(build(:supplier)).to be_valid
    end

    it "exige razão social" do
      supplier = build(:supplier, razao_social: nil)

      expect(supplier).not_to be_valid
    end

    it "exige CNPJ" do
      supplier = build(:supplier, cnpj: nil)

      expect(supplier).not_to be_valid
    end

    it "não permite CNPJ duplicado" do
      supplier = create(:supplier)

      duplicate = build(:supplier, cnpj: supplier.cnpj)

      expect(duplicate).not_to be_valid
    end

    it "aceita email vazio" do
      supplier = build(:supplier, email_contato: nil)

      expect(supplier).to be_valid
    end

    it "rejeita email inválido" do
      supplier = build(:supplier, email_contato: "email-invalido")

      expect(supplier).not_to be_valid
    end
  end
end