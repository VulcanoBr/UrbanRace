# frozen_string_literal: true

require "rails_helper"

RSpec.describe Athlete, type: :model do
  # ── subject válido para todos os testes ───────────────────────────────────
  subject(:athlete) { build(:athlete) }

  describe "validações" do
    it { is_expected.to have_secure_password }
    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_uniqueness_of(:email_address).case_insensitive }
    it { is_expected.to validate_presence_of(:nome) }
    it { is_expected.to validate_presence_of(:nascimento) }
    it { is_expected.to validate_presence_of(:sexo) }
    it { is_expected.to validate_presence_of(:cpf) }
    it { is_expected.to validate_uniqueness_of(:cpf).case_insensitive }
  end

  describe "sexo" do
    it "aceita M" do
      athlete.sexo = "masculino"
      expect(athlete).to be_valid
    end

    it "aceita F" do
      athlete.sexo = "feminino"
      expect(athlete).to be_valid
    end

    it "rejeita valor inválido" do
      athlete.sexo = "X"
      expect(athlete).not_to be_valid
    end
  end

  describe "normalizações" do
    it "strip e downcase no email_address" do
      a = build(:athlete, email_address: " ATLETA@Domain.COM ")
      a.valid?
      expect(a.email_address).to eq("atleta@domain.com")
    end

    it "remove não-dígitos do telefone" do
      a = build(:athlete, telefone: "(21) 98888-7777")
      a.valid?
      expect(a.telefone).to eq("21988887777")
    end
  end

  describe "#anonimizado?" do
    it "retorna true quando CPF inicia com LGPD-DEL-" do
      a = build(:athlete, cpf: "LGPD-DEL-12345678")
      expect(a).to be_anonimizado
    end

    it "retorna false para CPF normal" do
      a = build(:athlete, cpf: CPF.generate)
      expect(a).not_to be_anonimizado
    end
  end

  describe "autenticação" do
    let(:athlete) { create(:athlete, password: "atletapass123", password_confirmation: "atletapass123") }

    it "autentica com senha correta" do
      expect(athlete.authenticate("atletapass123")).to eq(athlete)
    end

    it "rejeita senha incorreta" do
      expect(athlete.authenticate("errada")).to be_falsy
    end
  end
end

