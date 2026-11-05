require "rails_helper"

RSpec.describe License, type: :model do
  describe "validações" do
    it "é válido com atributos obrigatórios" do
      expect(build(:license)).to be_valid
    end

    it "exige tipo" do
      license = build(:license, tipo: nil)

      expect(license).not_to be_valid
    end

    it "exige órgão responsável" do
      license = build(:license, orgao: nil)

      expect(license).not_to be_valid
    end

    it "exige prazo de aprovação" do
      license = build(:license, prazo_aprovacao: nil)

      expect(license).not_to be_valid
    end
  end

  describe "status" do
    it "usa pendente como padrão" do
      expect(build(:license).status).to eq("pendente")
    end
  end

  describe ".criticas" do
    it "inclui licenças pendentes com prazo nos próximos 7 dias" do
      license = create(
        :license,
        status: :pendente,
        prazo_aprovacao: 3.days.from_now
      )

      expect(described_class.criticas).to include(license)
    end

    it "inclui licenças vencidas com prazo nos próximos 7 dias" do
      license = create(
        :license,
        status: :vencido,
        prazo_aprovacao: 2.days.from_now
      )

      expect(described_class.criticas).to include(license)
    end

    it "não inclui licença aprovada" do
      license = create(
        :license,
        status: :aprovado,
        prazo_aprovacao: 2.days.from_now
      )

      expect(described_class.criticas).not_to include(license)
    end
  end
end