require "rails_helper"

RSpec.describe Sponsor, type: :model do
  describe "validações" do
    it "exige nome" do
      sponsor = build(:sponsor, nome: nil)

      expect(sponsor).not_to be_valid
    end

    it "exige CNPJ" do
      sponsor = build(:sponsor, cnpj: nil)

      expect(sponsor).not_to be_valid
    end

    it "não permite CNPJ duplicado" do
      sponsor = create(:sponsor)

      duplicate = build(:sponsor, cnpj: sponsor.cnpj)

      expect(duplicate).not_to be_valid
    end
  end

  describe "normalização" do
    it "normaliza email para lowercase e remove espaços" do
      sponsor = build(
        :sponsor,
        email_contato: "  CONTATO@EXEMPLO.COM "
      )

      expect(sponsor.email_contato).to eq("contato@exemplo.com")
    end

    it "remove protocolo e normaliza website" do
      sponsor = build(
        :sponsor,
        website: " HTTPS://EXEMPLO.COM "
      )

      expect(sponsor.website).to eq("exemplo.com")
    end
  end

  describe ".ativos" do
    it "retorna somente patrocinadores ativos" do
      ativo = create(:sponsor, ativo: true)
      inativo = create(:sponsor, ativo: false)

      expect(described_class.ativos).to include(ativo)
      expect(described_class.ativos).not_to include(inativo)
    end
  end

  describe "#status_class" do
    it "retorna classe de ativo" do
      expect(build(:sponsor, ativo: true).status_class)
        .to include("bg-green-50")
    end

    it "retorna classe de inativo" do
      expect(build(:sponsor, ativo: false).status_class)
        .to include("bg-red-50")
    end
  end
end