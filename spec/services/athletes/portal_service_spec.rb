# frozen_string_literal: true

require "rails_helper"

RSpec.describe Athletes::PortalService do
  let(:athlete) { create(:athlete) }

  subject(:service) { described_class.new(athlete) }

  describe "#dashboard_data" do
    it "retorna hash com próximas provas, provas passadas e inscrições pendentes" do
      data = service.dashboard_data
      expect(data).to have_key(:proximas_provas)
      expect(data).to have_key(:provas_passadas)
      expect(data).to have_key(:inscricoes_pendentes)
    end
  end
end
