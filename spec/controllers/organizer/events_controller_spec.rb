# spec/controllers/organizer/events_controller_spec.rb
require "rails_helper"

RSpec.describe Organizer::EventsController, type: :controller do
  let(:organizer) { create(:organizer) }
  let!(:event)    { create(:event, organizer: organizer) }

  before { sign_in_as_organizer_controller(organizer) }

  describe "GET #index" do
    it "retorna 200" do
      get :index
      expect(response).to have_http_status(:ok)
    end

    it "atribui @events com eventos do organizador" do
      get :index
      expect(assigns(:events)).to include(event)
    end

    it "não inclui eventos de outros organizadores" do
      outro_evento = create(:event, organizer: create(:organizer))
      get :index
      expect(assigns(:events)).not_to include(outro_evento)
    end
  end

  describe "GET #show" do
    it "retorna 200 com slug válido" do
      get :show, params: { id: event.slug_url }
      expect(response).to have_http_status(:ok)
    end

    it "levanta 404 para id numérico" do
      expect {
        get :show, params: { id: event.id.to_s }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "levanta 404 para slug inexistente" do
      expect {
        get :show, params: { id: "slug-nao-existe" }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "levanta 404 para evento de outro organizador" do
      outro_evento = create(:event, organizer: create(:organizer))
      expect {
        get :show, params: { id: outro_evento.slug_url }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "GET #edit" do
    it "retorna 200" do
      get :edit, params: { id: event.slug_url }
      expect(response).to have_http_status(:ok)
    end

    it "atribui @event_form carregado do model" do
      get :edit, params: { id: event.slug_url }
      form = assigns(:event_form)
      expect(form).to be_a(Organizer::EventForm)
      expect(form.id).to eq(event.id)
      expect(form.nome).to eq(event.nome)
    end
  end

  describe "PATCH #update" do
    let(:valid_params) do
      {
        id: event.slug_url,
        organizer_event_form: {
          nome:            "Nome Novo",
          descricao:       event.descricao,
          cidade:          event.cidade,
          estado:          event.estado,
          local_partida:   event.local_partida,
          data_largada:    event.data_largada,
          horario_largada: event.horario_largada,
          slug_url:        event.slug_url,
          status:          event.status,
          limite_atletas:  event.limite_atletas
        }
      }
    end

    context "dados válidos" do
      before { patch :update, params: valid_params }

      it "atualiza o nome do evento" do
        expect(event.reload.nome).to eq("Nome Novo")
      end

      it "redireciona após update" do
        expect(response).to have_http_status(:redirect)
      end

      it "redireciona para URL com slug (não com id numérico)" do
        expect(response.location).to include(event.reload.slug_url)
      end

      it "NÃO redireciona para URL com id numérico" do
        expect(response.location).not_to match(%r{/organizer/events/#{event.id}$})
      end
    end

    context "dados inválidos" do
      let(:invalid_params) do
        valid_params.deep_merge(
          organizer_event_form: { nome: "", limite_atletas: -1 }
        )
      end

      before { patch :update, params: invalid_params }

      it "renderiza edit novamente" do
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "não atualiza o evento" do
        expect(event.reload.nome).not_to eq("")
      end
    end
  end

  describe "POST #create" do
    let(:valid_params) do
      {
        organizer_event_form: {
          nome:            "Novo Evento",
          descricao:       "Descrição",
          cidade:          "São Paulo",
          estado:          "SP",
          local_partida:   "Ibirapuera",
          data_largada:    3.months.from_now.to_date,
          horario_largada: "07:00",
          slug_url:        "novo-evento-#{SecureRandom.hex(3)}",
          status:          "draft",
          limite_atletas:  400
        }
      }
    end

    it "cria novo evento" do
      expect { post :create, params: valid_params }.to change(Event, :count).by(1)
    end

    it "redireciona para o evento criado pelo slug" do
      post :create, params: valid_params
      novo = Event.order(:created_at).last
      expect(response.location).to include(novo.slug_url)
    end
  end

  describe "DELETE #destroy" do
    it "remove o evento" do
      expect {
        delete :destroy, params: { id: event.slug_url }
      }.to change(Event, :count).by(-1)
    end

    it "redireciona para index" do
      delete :destroy, params: { id: event.slug_url }
      expect(response).to redirect_to(organizer_events_path)
    end

    it "não permite excluir evento de outro organizador" do
      outro = create(:event, organizer: create(:organizer))
      expect {
        delete :destroy, params: { id: outro.slug_url }
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "sem autenticação" do
    before do
      allow(Current).to receive(:session).and_return(nil)
      allow(Current).to receive(:user).and_return(nil)
    end

    it "redireciona para login no index" do
      get :index
      expect(response).to redirect_to(new_session_path)  # ← corrigido
    end
  end
end