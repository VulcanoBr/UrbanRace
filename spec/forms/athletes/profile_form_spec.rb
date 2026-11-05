# frozen_string_literal: true

require "rails_helper"

RSpec.describe Athletes::ProfileForm, type: :model do
  let(:athlete) { create(:athlete, nome: "Nome Antigo", telefone: "21988888888") }

  it "carrega os dados do atleta via .from_model" do
    form = described_class.from_model(athlete)
    expect(form.nome).to eq("Nome Antigo")
    expect(form.telefone).to eq("21988888888")
  end

  it "atualiza o nome e telefone limpo" do
    form = described_class.new(
      athlete_id: athlete.id,
      nome: "Nome Novo",
      telefone: "(21) 97777-6666"
    )

    expect(form.save).to be true
    athlete.reload
    expect(athlete.nome).to eq("Nome Novo")
    expect(athlete.telefone).to eq("21977776666")
  end

  it "valida quantidade de dígitos do telefone" do
    form = described_class.new(
      athlete_id: athlete.id,
      nome: "Nome",
      telefone: "123"
    )
    expect(form.save).to be false
    expect(form.errors[:telefone]).to be_present
  end
end
