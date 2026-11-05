# frozen_string_literal: true

require "rails_helper"

RSpec.describe Category, type: :model do
  describe "validações" do
    it { is_expected.to validate_presence_of(:nome) }
    it { is_expected.to validate_presence_of(:sexo) }
    it { is_expected.to validate_presence_of(:idade_min) }
    it { is_expected.to validate_presence_of(:idade_max) }

    it "valida que idade_max é maior que idade_min" do
      category = build(:category, idade_min: 30, idade_max: 25)
      expect(category).not_to be_valid
      expect(category.errors[:idade_max]).to include("deve ser maior que 30")
    end
  end

  describe "#faixa_etaria" do
    it "retorna a string formatada" do
      category = build(:category, idade_min: 18, idade_max: 29)
      expect(category.faixa_etaria).to eq("18 - 29 anos")
    end
  end

  describe "#erros_de_elegibilidade" do
    let(:event) { create(:event, data_largada: Date.new(2026, 11, 15)) }
    let(:distance) { create(:distance, event: event) }
    let(:category) { create(:category, distance: distance, sexo: "masculino", idade_min: 18, idade_max: 30) }

    it "retorna array vazio quando atleta é elegível" do
      athlete = build(:athlete, sexo: "M", nascimento: Date.new(1998, 5, 20))
      expect(category.erros_de_elegibilidade(athlete, reference_date: event.data_largada.to_date)).to be_empty
    end

    it "retorna erro de idade quando atleta é mais novo que a idade mínima" do
      athlete = build(:athlete, sexo: "M", nascimento: Date.new(2010, 1, 1))
      erros = category.erros_de_elegibilidade(athlete, reference_date: event.data_largada.to_date)
      expect(erros.first).to match(/Idade incompatível/)
    end

    it "retorna erro de sexo quando sexo não corresponde à categoria" do
      athlete = build(:athlete, sexo: "F", nascimento: Date.new(1998, 5, 20))
      erros = category.erros_de_elegibilidade(athlete, reference_date: event.data_largada.to_date)
      expect(erros.first).to match(/Sexo incompatível/)
    end

    it "aceita qualquer sexo para categoria unissex" do
      unissex_cat = create(:category, distance: distance, sexo: "unissex", idade_min: 18, idade_max: 99)
      female_athlete = build(:athlete, sexo: "F", nascimento: Date.new(1995, 1, 1))
      expect(unissex_cat.erros_de_elegibilidade(female_athlete, reference_date: event.data_largada.to_date)).to be_empty
    end
  end
end