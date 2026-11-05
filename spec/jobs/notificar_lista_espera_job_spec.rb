# frozen_string_literal: true

require "rails_helper"

RSpec.describe NotificarListaEsperaJob, type: :job do
  let(:distance) { create(:distance) }
  let!(:waitlist) { create(:waitlist, distance: distance, status: "aguardando", posicao: 1) }

  it "notifica o próximo atleta da fila e altera o status para notificado" do
    described_class.perform_now(distance.id, 1)

    expect(waitlist.reload.status).to eq("notificado")
  end
end
