# frozen_string_literal: true

require "rails_helper"

RSpec.describe Athletes::TransferForm, type: :model do
  let(:origem) { create(:athlete) }
  let(:registration) { create(:registration, :confirmado, athlete: origem) }

  it "valida presença dos dados de destino" do
    form = described_class.new(registration_id: registration.id, athlete_origem_id: origem.id)
    expect(form).not_to be_valid
    expect(form.errors[:cpf_destino]).to be_present
    expect(form.errors[:email_destino]).to be_present
  end

  it "não permite transferir para o próprio CPF" do
    form = described_class.new(
      registration_id: registration.id,
      athlete_origem_id: origem.id,
      cpf_destino: origem.cpf,
      email_destino: "destino@example.com"
    )
    expect(form.save).to be false
    expect(form.errors[:cpf_destino]).to include("não pode ser o seu próprio CPF.")
  end
end
