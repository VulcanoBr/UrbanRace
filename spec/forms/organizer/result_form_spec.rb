# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organizer::ResultForm, type: :model do
  let(:event) { create(:event) }
  let(:registration) { create(:registration, event: event) }

  it "agenda Certificates::GenerateSingleJob ao homologar resultado" do
    form = described_class.new(
      registration_id: registration.id,
      event_id: event.id,
      posicao_geral: 1,
      posicao_categoria: 1,
      posicao_sexo: 1,
      tempo_liquido: "00:40:00",
      status_finalizacao: "concluido",
      homologado: true
    )

    expect { form.save }.to have_enqueued_job(Certificates::GenerateSingleJob)
    expect(Result.last.homologado).to be true
  end
end
