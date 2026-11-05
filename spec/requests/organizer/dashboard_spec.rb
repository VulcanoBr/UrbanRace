require "rails_helper"

RSpec.describe "Organizer::Dashboard", type: :request do
  let(:organizer) { create(:organizer) }

  describe "GET /organizer/dashboard" do
    context "logado" do
      before { sign_in_as_organizer(organizer) }

      it "retorna 200" do
        get organizer_root_path
        expect(response).to have_http_status(:ok)
      end
    end

    context "sem autenticação" do
      it "redireciona para login" do
        get organizer_root_path
        expect(response).to redirect_to(new_session_path)
      end
    end
  end
end
