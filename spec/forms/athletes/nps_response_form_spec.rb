# frozen_string_literal: true

require "rails_helper"

RSpec.describe Athletes::NpsResponseForm, type: :model do
  describe "validações" do
    it { is_expected.to validate_presence_of(:nota_geral) }
    it { is_expected.to validate_inclusion_of(:nota_geral).in_range(0..10) }
  end

  describe "#save" do
    let(:athlete) { create(:athlete) }
    let(:event) { create(:event) }
    let(:registration) { create(:registration, athlete: athlete, event: event) }
    let!(:result) { create(:result, registration: registration, event: event) }

    it "cria um registro de NpsResponse" do
      form = described_class.new(
        registration_id: registration.id,
        nota_geral: 10,
        nota_percurso: 9,
        comentario: "Excelente prova!"
      )

      expect { form.save }.to change(NpsResponse, :count).by(1)
      response = NpsResponse.last
      expect(response.athlete_id).to eq(athlete.id)
      expect(response.nota_geral).to eq(10)
    end
  end
end
