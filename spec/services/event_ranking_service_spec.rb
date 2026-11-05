# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventRankingService do
  let(:event) { create(:event) }
  let(:distance) { create(:distance, event: event) }
  let(:category) { create(:category, distance: distance) }

  subject(:service) { described_class.new(event) }

  describe "#ranking" do
    it "retorna resultados homologados ordenados por posição na categoria" do
      reg1 = create(:registration, event: event, distance: distance, category: category)
      create(:result, :homologado, registration: reg1, event: event, posicao_categoria: 1)

      ranking = service.ranking(distance: distance, category: category)
      expect(ranking.size).to eq(1)
    end
  end
end
