require "rails_helper"

RSpec.describe "Organizer::Registrations", type: :request do
  let(:organizer)    { create(:organizer) }
  let(:event)        { create(:event, :published, organizer: organizer) }
  let!(:confirmed)   { create(:registration, :confirmed, event: event) }
  let!(:pending_reg) { create(:registration, event: event) }
  let!(:cancelled)   { create(:registration, :cancelled, event: event) }

  before { sign_in_as_organizer(organizer) }

  describe "GET /organizer/events/:event_id/registrations" do
    it "retorna 200" do
      get organizer_event_registrations_path(event)
      expect(response).to have_http_status(:ok)
    end

    it "lista inscrições do evento" do
      get organizer_event_registrations_path(event)
      expect(response.body).to include(confirmed.athlete.nome)
    end
  end

end
