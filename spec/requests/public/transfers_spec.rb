# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Public::Transfers", type: :request do
  let(:pending_transfer) { create(:pending_transfer) }

  describe "GET /transferencia/:token" do
    it "renderiza a página de aceite de convite de transferência" do
      token = pending_transfer.generate_token_for(:acceptance)
      get transfer_invite_path(token: token)
      expect(response).to have_http_status(:ok)
    end
  end
end
