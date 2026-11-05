# frozen_string_literal: true

require "rails_helper"

RSpec.describe Distance, type: :model do
  describe "validações" do
    it { is_expected.to validate_presence_of(:nome) }
    it { is_expected.to validate_presence_of(:km) }
    it { is_expected.to validate_presence_of(:vagas_total) }
  end

  describe "#vagas_disponiveis" do
    it "calcula vagas_total - vagas_ocupadas" do
      distance = build(:distance, vagas_total: 200, vagas_ocupadas: 50)
      expect(distance.vagas_disponiveis).to eq(150)
    end
  end

  describe "#sold_out? e #esgotada?" do
    it "retorna true quando não restam vagas" do
      distance = build(:distance, vagas_total: 100, vagas_ocupadas: 100)
      expect(distance).to be_sold_out
      expect(distance).to be_esgotada
    end

    it "retorna false quando há vagas disponíveis" do
      distance = build(:distance, vagas_total: 100, vagas_ocupadas: 50)
      expect(distance).not_to be_sold_out
    end
  end

  describe "#percentual_ocupacao" do
    it "calcula percentual arredondado" do
      distance = build(:distance, vagas_total: 200, vagas_ocupadas: 50)
      expect(distance.percentual_ocupacao).to eq(25)
    end

    it "retorna 0 quando vagas_total é zero" do
      distance = build(:distance, vagas_total: 0, vagas_ocupadas: 0)
      expect(distance.percentual_ocupacao).to eq(0)
    end
  end
end