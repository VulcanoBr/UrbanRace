# frozen_string_literal: true

require "rails_helper"

RSpec.describe Athletes::ResultsService do
  let(:athlete) { create(:athlete) }

  subject(:service) { described_class.new(athlete) }

  describe "#call" do
    it "retorna hash com resumo, estatísticas e resultados" do
      result = service.call
      expect(result).to have_key(:resumo)
      expect(result).to have_key(:estatisticas)
      expect(result).to have_key(:resultados)
    end
  end
end
