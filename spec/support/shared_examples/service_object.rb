# frozen_string_literal: true

# Shared example para garantir que um Service Object segue o padrão esperado
# Uso:
#   it_behaves_like "um service object"
RSpec.shared_examples "um service object" do
  describe "interface padrão" do
    it "responde ao método de classe .call" do
      expect(described_class).to respond_to(:call)
    end
  end
end
