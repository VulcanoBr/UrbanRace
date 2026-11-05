# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organizer::AthleteForm, type: :model do
  it "cria um novo atleta com dados válidos" do
    form = described_class.new(
      nome: "Carlos Silva",
      email_address: "carlos@example.com",
      cpf: CPF.generate,
      nascimento: 25.years.ago.to_date,
      sexo: "masculino",
      telefone: "(21) 98888-9999",
      password: "password123",
      password_confirmation: "password123"
    )

    expect(form.save).to be true
    expect(Athlete.find_by(email_address: "carlos@example.com")).to be_present
  end

  it "valida unicidade do e-mail" do
    existing = create(:athlete, email_address: "existente@example.com")
    form = described_class.new(
      nome: "Novo Atleta",
      email_address: "existente@example.com",
      cpf: CPF.generate,
      nascimento: 25.years.ago.to_date,
      sexo: "M",
      telefone: "21988889999",
      password: "password123",
      password_confirmation: "password123"
    )

    expect(form.save).to be false
    expect(form.errors[:email_address]).to include("já está em uso")
  end
end
