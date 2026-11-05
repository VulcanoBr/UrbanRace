# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organizer::LotForm, type: :model do
  let(:distance) { create(:distance, vagas_total: 100) }

  it "valida limite de vagas projetadas da distância" do
    form = described_class.new(
      distance_id: distance.id,
      numero: 1,
      preco: "100.00",
      vagas: 150,
      abertura: Time.current,
      encerramento: 10.days.from_now,
      status: "active"
    )

    expect(form.save).to be false
    expect(form.errors[:vagas]).to include(a_string_matching(/não pode exceder o limite da distância/))
  end

  it "cria lote com preço convertido de string para float" do
    form = described_class.new(
      distance_id: distance.id,
      numero: 1,
      preco: "R$ 150.50",
      vagas: 50,
      abertura: Time.current,
      encerramento: 10.days.from_now,
      status: "active"
    )

    expect(form.save).to be true
    lot = Lot.last
    expect(lot.preco).to eq(150.50)
  end
end
