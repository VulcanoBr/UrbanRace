# frozen_string_literal: true

require "rails_helper"

RSpec.describe Athletes::PerformanceService do
  let(:event) { create(:event) }
  let(:distance) { create(:distance, event: event, km: 10.0) }
  let(:registration) { create(:registration, event: event, distance: distance) }
  let(:result) { create(:result, :homologado, registration: registration, event: event, tempo_liquido: "00:50:00", posicao_geral: 1) }

  subject(:service) { described_class.new(result) }

  describe "#data" do
    it "retorna hash com estatísticas de desempenho" do
      data = service.data
      expect(data).to have_key(:percentual_superado)
      expect(data).to have_key(:velocidade_media)
      expect(data).to have_key(:ritmo)
    end
  end
end
