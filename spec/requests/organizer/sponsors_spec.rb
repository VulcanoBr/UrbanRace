# spec/requests/organizer/sponsors_spec.rb
require "rails_helper"

RSpec.describe "Organizer::Sponsors", type: :request do
  let(:organizer) { create(:organizer) }
  let!(:sponsor)  { create(:sponsor) }  # sem event: — sponsor é global

  before { sign_in_as_organizer(organizer) }

  describe "GET /organizer/sponsors" do
    it "retorna 200" do
      get organizer_sponsors_path
      expect(response).to have_http_status(:ok)
    end

    it "lista os patrocinadores" do
      get organizer_sponsors_path
      expect(response.body).to include(sponsor.nome)
    end
  end

  describe "POST /organizer/sponsors" do
    let(:valid_params) do
      {
        organizer_sponsor_form: {
          nome:          "Patrocinador Novo",
          cnpj:          "12345678000195",
          contato:       "João Silva",
          email_contato: "joao@novo.com",
          phone_contato: "21966666666",
          website:       "www.novo.com",
          ativo:         true
        }
      }
    end

    it "cria patrocinador" do
      expect { post organizer_sponsors_path, params: valid_params }
        .to change(Sponsor, :count).by(1)
    end
  end

  describe "DELETE /organizer/sponsors/:id" do
    it "remove o patrocinador" do
      expect { delete organizer_sponsor_path(sponsor) }
        .to change(Sponsor, :count).by(-1)
    end
  end
end
