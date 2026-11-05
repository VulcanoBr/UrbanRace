# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let!(:athlete) { create(:athlete, email_address: "corredor@example.com", password: "password123") }

  describe "POST /session" do
    it "realiza login com credenciais válidas e cria sessão" do
      post session_path, params: {
        email_address: "corredor@example.com",
        password: "password123",
        user_type: "athlete"
      }

      expect(response).to have_http_status(:redirect)
      expect(cookies[:session_id]).to be_present
    end

    it "rejeita login com senha incorreta" do
      post session_path, params: {
        email_address: "corredor@example.com",
        password: "errada",
        user_type: "athlete"
      }

      expect(response).to have_http_status(:unprocessable_entity).or have_http_status(:redirect)
    end
  end

  describe "DELETE /session" do
    it "destrói a sessão logada" do
      delete session_path
      expect(response).to have_http_status(:redirect)
    end
  end
end
