# frozen_string_literal: true

require "rails_helper"

RSpec.describe Athletes::PrivacyRequestForm, type: :model do
  let(:athlete) { create(:athlete, password: "password123") }

  it "solicita anonimização com a senha correta e confirmação" do
    form = described_class.new(
      athlete_id: athlete.id,
      password: "password123",
      confirm_erasure: true
    )

    expect(form.process).to be true
    expect(athlete.reload).to be_anonimizado
  end

  it "recusa anonimização com senha incorreta" do
    form = described_class.new(
      athlete_id: athlete.id,
      password: "errada",
      confirm_erasure: true
    )

    expect(form.process).to be false
    expect(form.errors[:password]).to include("está incorreta")
  end
end
