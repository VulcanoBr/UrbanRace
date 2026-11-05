# frozen_string_literal: true

require "rails_helper"

RSpec.describe Operation::IncidentForm, type: :model do
  let(:event) { create(:event) }
  let(:organizer) { create(:organizer) }

  it "valida que dorsal existe no evento se for informado" do
    form = described_class.new(
      event_id: event.id,
      organizer_id: organizer.id,
      dorsal: 999,
      tipo: "queda",
      gravidade: "baixa",
      km_local: 3.5,
      descricao: "Queda leve"
    )

    expect(form.save).to be false
    expect(form.errors[:dorsal]).to include("não encontrado neste evento. Verifique o número.")
  end
end
