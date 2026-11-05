require "rails_helper"

# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Organizer::Events", type: :request do
  let(:organizer) { create(:organizer, role: "admin") }
  let!(:event)    { create(:event, organizer: organizer) }

  before { sign_in_as_organizer(organizer) }

  describe "GET /organizer/events" do
    it "retorna 200" do
      get organizer_events_path

      expect(response).to have_http_status(:ok)
    end

    it "exibe os eventos do organizador" do
      get organizer_events_path

      expect(response.body).to include(event.nome)
    end

    it "não exibe eventos de outros organizadores" do
      outro = create(:organizer, role: "admin")
      create(
        :event,
        organizer: outro,
        nome: "Evento Secreto"
      )

      get organizer_events_path

      expect(response.body).not_to include("Evento Secreto")
    end
  end

  describe "GET /organizer/events/:id" do
    it "retorna 200 com slug válido" do
      get organizer_event_path(event)

      expect(response).to have_http_status(:ok)
    end

    it "retorna 404 para slug inexistente" do
      get organizer_event_path("slug-que-nao-existe")

      expect(response).to have_http_status(:not_found)
    end

    it "retorna 404 quando id numérico é passado" do
      get organizer_event_path(event.id.to_s)

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /organizer/events/:id/edit" do
    it "retorna 200" do
      get edit_organizer_event_path(event)

      expect(response).to have_http_status(:ok)
    end

    it "exibe o nome do evento no formulário" do
      get edit_organizer_event_path(event)

      expect(response.body).to include(event.nome)
    end
  end

  describe "PATCH /organizer/events/:id" do
    let(:new_attrs) do
      {
        organizer_event_form: {
          nome:            "Nome Atualizado",
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

    it "atualiza o evento e retorna redirect" do
      patch organizer_event_path(event), params: new_attrs

      expect(response).to have_http_status(:redirect)
    end

    it "persiste o novo nome" do
      patch organizer_event_path(event), params: new_attrs

      expect(event.reload.nome).to eq("Nome Atualizado")
    end

    it "redireciona para a URL com slug" do
      patch organizer_event_path(event), params: new_attrs

      expect(response).to redirect_to_slug_of(event.reload)
    end

    it "não redireciona para URL com id numérico" do
      patch organizer_event_path(event), params: new_attrs

      expect(response.location).not_to match(%r{/organizer/events/\d+$})
    end

    it "redireciona para show do evento" do
      patch organizer_event_path(event), params: new_attrs

      follow_redirect!

      expect(response).to have_http_status(:ok)
    end

    context "com dados inválidos" do
      let(:invalid_attrs) do
        {
          organizer_event_form:
            new_attrs[:organizer_event_form].merge(nome: "")
        }
      end

      it "retorna status de validação" do
        patch organizer_event_path(event), params: invalid_attrs

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "não atualiza o nome" do
        patch organizer_event_path(event), params: invalid_attrs

        expect(event.reload.nome).not_to eq("")
      end
    end

    context "quando slug_url muda" do
      it "redireciona para o novo slug" do
        novo_slug = "novo-slug-#{SecureRandom.hex(4)}"

        patch organizer_event_path(event),
              params: {
                organizer_event_form:
                  new_attrs[:organizer_event_form].merge(
                    slug_url: novo_slug
                  )
              }

        expect(response.location).to include(novo_slug)
      end
    end

    context "sem autenticação" do
      before { sign_out }

      it "redireciona para login" do
        patch organizer_event_path(event), params: new_attrs

        expect(response).to redirect_to(new_session_path)
      end
    end
  end

  describe "POST /organizer/events" do
    let(:valid_params) do
      {
        organizer_event_form: {
          nome: "Nova Corrida 2026",
          descricao: "Descrição",
          cidade: "São Paulo",
          estado: "SP",
          local_partida: "Ibirapuera",
          data_largada: 3.months.from_now.to_date.to_s,
          horario_largada: "07:00",
          slug_url: "nova-corrida-#{SecureRandom.hex(4)}",
          status: "draft",
          limite_atletas: 300
        }
      }
    end

    it "cria novo evento" do
      expect do
        post organizer_events_path, params: valid_params
      end.to change(Event, :count).by(1)
    end

    it "redireciona após criação" do
      post organizer_events_path, params: valid_params

      expect(response).to have_http_status(:redirect)
    end

    it "redireciona para URL com slug" do
      post organizer_events_path, params: valid_params

      evento_criado = Event.order(:created_at).last

      expect(response.location).to include(evento_criado.slug_url)
      expect(response.location).not_to match(%r{/\d+})
    end
  end

  describe "DELETE /organizer/events/:id" do
    it "remove o evento" do
      expect do
        delete organizer_event_path(event)
      end.to change(Event, :count).by(-1)
    end

    it "redireciona para index" do
      delete organizer_event_path(event)

      expect(response).to redirect_to(organizer_events_path)
    end

    it "não permite excluir evento de outro organizador" do
      outro_org = create(:organizer, role: "admin")
      outro_event = create(:event, organizer: outro_org)

      expect do
        delete organizer_event_path(outro_event)
      end.not_to change(Event, :count)
    end
  end

  private

  def sign_out
    delete session_path
  end
end
