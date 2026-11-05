# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExpirarListaEsperaJob, type: :job do
  it "marca como expirada a waitlist notificada há mais de 48h" do
    waitlist = create(:waitlist, status: "notificado", updated_at: 50.hours.ago)

    described_class.perform_now

    expect(waitlist.reload.status).to eq("expirado")
  end

  it "não altera waitlists dentro do prazo de 48h" do
    waitlist = create(:waitlist, status: "notificado", updated_at: 10.hours.ago)

    described_class.perform_now

    expect(waitlist.reload.status).to eq("notificado")
  end
end
