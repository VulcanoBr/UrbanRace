require "rails_helper"

RSpec.describe "Organizer::Distances", type: :request do
  let(:organizer) { create(:organizer) }
  let(:event)     { create(:event, organizer: organizer) }
  let!(:distance) { create(:distance, event: event) }

  before { sign_in_as_organizer(organizer) }

  describe "GET /organizer/events/:event_id/distances" do
    it "retorna 200" do
      get organizer_event_distances_path(event)
      expect(response).to have_http_status(:ok)
    end

    it "lista as distâncias" do
      get organizer_event_distances_path(event)
      expect(response.body).to include(distance.nome)
    end
  end

  describe "POST /organizer/events/:event_id/distances" do
    let(:valid_params) do
      { organizer_distance_form: { nome: "10K", km: 10.0, vagas_total: 300 } }
    end

    it "cria distância" do
      expect { post organizer_event_distances_path(event), params: valid_params }
        .to change(Distance, :count).by(1)
    end

    it "redireciona após criar" do
      post organizer_event_distances_path(event), params: valid_params
      expect(response).to have_http_status(:redirect)
    end

    it "rejeita km zero ou negativo" do
      invalid_params = { organizer_distance_form: { nome: "0K", km: 0, vagas_total: 100 } }
      post organizer_event_distances_path(event), params: invalid_params
      expect(Distance.count).to eq(1) # apenas a já existente
    end
  end

  describe "PATCH /organizer/events/:event_id/distances/:id" do
    it "atualiza a distância" do
      # Utilize o helper conforme definido em config/routes.rb (ex: organizer_distance_path ou organizer_event_distance_path)
      patch organizer_distance_path(distance),
            params: { organizer_distance_form: { vagas_total: 500 } }
      expect(distance.reload.vagas_total).to eq(500)
    end
  end

  describe "DELETE /organizer/events/:event_id/distances/:id" do
    it "remove a distância sem inscrições" do
      expect { delete organizer_distance_path(distance) }
        .to change(Distance, :count).by(-1)
    end

    it "não remove distância com inscrições" do
      create(:registration, event: event, distance: distance) # Garante parâmetro válido
      expect { delete organizer_distance_path(distance) }
        .not_to change(Distance, :count)
    end
  end
end