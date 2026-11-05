# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organizer::RegistrationForm, type: :model do
  let(:event) { create(:event) }
  let(:distance) { create(:distance, event: event) }
  let(:category) { create(:category, distance: distance) }
  let(:lot) { create(:lot, distance: distance) }
  let(:athlete) { create(:athlete) }

  it "valida que a distância pertence ao evento selecionado" do
    other_event = create(:event)
    other_distance = create(:distance, event: other_event)

    form = described_class.new(
      athlete_id: athlete.id,
      event_id: event.id,
      distance_id: other_distance.id,
      category_id: category.id,
      lot_id: lot.id,
      tamanho_kit: "M",
      contato_emergencia: "Maria",
      fone_emergencia: "21999999999"
    )

    expect(form.save).to be false
    expect(form.errors[:distance_id]).to include("não pertence ao evento selecionado")
  end
end
