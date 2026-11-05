# frozen_string_literal: true

# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Public::Registrations", type: :request do
  let(:event) { create(:event, :published, slug_url: "corrida-rio-2026") }
  let!(:distance) { create(:distance, event: event) }
  let!(:category) { create(:category, distance: distance) }
  let!(:lot) { create(:lot, :vigente, distance: distance) }

  describe "GET /corridas/:slug/inscrever" do
    it "renderiza a página pública de inscrição com sucesso" do
      get new_public_registration_path(
        slug: event.slug_url,
        distance_id: distance.id
      )

      expect(response).to have_http_status(:ok)
    end

    it "redireciona quando nenhuma distância é informada" do
      get new_public_registration_path(slug: event.slug_url)

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(
        public_event_path(event.slug_url)
      )
    end

    it "redireciona quando a distância não pertence ao evento" do
      outro_evento = create(
        :event,
        :published,
        slug_url: "outra-corrida-2026"
      )

      outra_distance = create(
        :distance,
        event: outro_evento
      )

      get new_public_registration_path(
        slug: event.slug_url,
        distance_id: outra_distance.id
      )

      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(
        public_event_path(event.slug_url)
      )
    end
  end
end