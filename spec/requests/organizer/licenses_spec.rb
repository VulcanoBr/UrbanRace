require "rails_helper"

RSpec.describe "Organizer::Licenses", type: :request do
  let(:organizer) { create(:organizer) }
  let(:event)     { create(:event, organizer: organizer) }
  let!(:license)  { create(:license, event: event) }

  before { sign_in_as_organizer(organizer) }

  describe "GET /organizer/events/:event_id/licenses" do
    it "retorna 200" do
      get organizer_event_licenses_path(event)
      expect(response).to have_http_status(:ok)
    end

    it "exibe as licenças do evento" do  
      get organizer_event_licenses_path(event)  
      expect(response.body).to include(license.tipo)  
    end

    it "destaca licenças vencendo em breve" do  
      vencendo = create(:license, :expiring_soon, event: event)  
      get organizer_event_licenses_path(event)  
      expect(response.body).to include(vencendo.orgao)  
    end  
  end

  describe "GET /organizer/events/:event_id/licenses/new" do
    it "retorna 200" do
      get new_organizer_event_license_path(event)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /organizer/events/:event_id/licenses" do
    let(:valid_params) do
      {
        organizer_license_form: {
          tipo:             "Alvará da Prefeitura",
          orgao:            "Prefeitura do Rio",
          prazo_solicitacao: 30.days.from_now.to_date.to_s,
          prazo_aprovacao:   15.days.from_now.to_date.to_s,
          status:           "pendente"
        }
      }
    end

    it "cria licença" do  
      expect { post organizer_event_licenses_path(event), params: valid_params }  
        .to change(License, :count).by(1)  
    end

    it "redireciona após criar" do  
      post organizer_event_licenses_path(event), params: valid_params  
      expect(response).to have_http_status(:redirect)  
    end  
  end

  describe "PATCH /organizer/events/:event_id/licenses/:id" do
    it "atualiza a licença" do
      patch organizer_event_license_path(event, license),
            params: { organizer_license_form: { status: "aprovado" } }

      expect(license.reload.status).to eq("aprovado")
    end
  end

  describe "DELETE /organizer/events/:event_id/licenses/:id" do
    it "remove a licença" do
      expect { delete organizer_event_license_path(event, license) }
        .to change(License, :count).by(-1)
    end
  end
end
