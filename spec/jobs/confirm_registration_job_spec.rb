# frozen_string_literal: true
# spec/jobs/confirm_registration_job_spec.rb
require "rails_helper"

RSpec.describe ConfirmRegistrationJob, type: :job do
  let(:event)        { create(:event) }
  # NÃO crie category separada — deixa a factory de registration montar
  let(:registration) { create(:registration, :pendente, event: event) }
  let!(:payment)     { create(:payment, registration: registration, status: "pendente") }

  it "confirma a inscrição, atribui dorsal e marca pagamento como pago" do
    described_class.perform_now(registration.id)

    registration.reload
    expect(registration.confirmado?).to be true          # usa o predicado do enum
    expect(registration.numero_dorsal).to be_present
    expect(registration.payment.reload.status).to eq("pago")
  end

  it "é idempotente para inscrições já confirmadas" do
    registration.update!(status: "confirmed", numero_dorsal: 101)

    expect {
      described_class.perform_now(registration.id)
    }.not_to change { registration.reload.numero_dorsal }
  end
end
