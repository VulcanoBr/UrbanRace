# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organizer::EventForm, type: :model do
  let(:organizer) { create(:organizer) }

  it "cria um novo evento com slug parametrizado" do
    form = described_class.new(
      organizer_id: organizer.id,
      nome: "Corrida Noturna Rio 2026",
      cidade: "Rio de Janeiro",
      estado: "RJ",
      local_partida: "Aterro do Flamengo",
      data_largada: 30.days.from_now.to_date,
      horario_largada: "20:00",
      slug_url: "corrida-noturna-rio-2026",
      limite_atletas: 500,
      status: "draft"
    )

    expect(form.save).to be true
    event = Event.find_by(slug_url: "corrida-noturna-rio-2026")
    expect(event).to be_present
    expect(event.nome).to eq("Corrida Noturna Rio 2026")
  end
end
