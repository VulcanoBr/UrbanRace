require "rails_helper"

RSpec.describe "Organizer::Sessions", type: :request do
  let!(:organizer) do
    create(:organizer,  role: "admin", password: "senha123", password_confirmation: "senha123")
  end

  # helper local para não depender do sign_in_as_organizer do AuthHelpers aqui
  def login(password: "senha123")
    post session_path, params: {
      email_address: organizer.email_address,
      password:      password,
      user_type:     "organizer"
    }
  end

  describe "POST /session (login como organizer)" do

    context "com credenciais válidas" do
      it "autentica e redireciona" do
        login
        expect(response).to have_http_status(:redirect)
      end

      it "redireciona para o dashboard" do
        post session_path, params: {
          user_type: "organizer",
          email_address: organizer.email_address,
          password: "senha123"
        }

        expect(response).to redirect_to(organizer_dashboard_path)
      end
    end

    context "com senha errada" do
      it "retorna status de falha" do
        login(password: "errada")
        expect(response).to have_http_status(:unprocessable_content)
      end

      it "não cria sessão" do
        expect {
          login(password: "errada")
        }.not_to change(Session, :count)
      end
    end

    context "com email inexistente" do
      it "não autentica" do
        post session_path, params: {
          email_address: "fake@email.com",
          password:      "qualquer",
          user_type:     "organizer"
        }
        expect(response).not_to redirect_to(organizer_root_path)
      end
    end
  end

  describe "DELETE /session (logout)" do
  it "destrói a sessão e retorna para a página inicial" do
    post session_path, params: {
      user_type: "organizer",
      email_address: organizer.email_address,
      password: "senha123"
    }

    expect(response).to have_http_status(:redirect)

    expect do
      delete session_path
    end.to change(Session, :count).by(-1)

    expect(response).to redirect_to(root_path)
  end
end
end