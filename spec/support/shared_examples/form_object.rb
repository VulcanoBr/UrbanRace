# frozen_string_literal: true

# Shared example para garantir que um Form Object segue o padrão esperado
# Uso:
#   it_behaves_like "um form object", required_attrs: { nome: "Teste" }
RSpec.shared_examples "um form object" do |required_attrs: {}|
  describe "interface padrão" do
    subject(:form) { described_class.new(required_attrs) }

    it "responde a #valid?" do
      expect(form).to respond_to(:valid?)
    end

    it "responde a #save" do
      expect(form).to respond_to(:save)
    end

    it "responde a #errors" do
      expect(form).to respond_to(:errors)
    end

    it "responde a #persisted?" do
      expect(form).to respond_to(:persisted?)
    end
  end

  describe "validações" do
    it "é inválido sem atributos obrigatórios" do
      expect(described_class.new).to be_invalid
    end
  end
end
