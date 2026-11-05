# frozen_string_literal: true

require "rails_helper"

RSpec.describe ExpireTransferInviteJob, type: :job do
  let(:transfer) { create(:transfer, status: "pendente") }
  let!(:pending) { create(:pending_transfer, transfer: transfer, status: "aguardando", expira_em: 1.hour.ago) }

  before do
    # Stub do método ausente TransferMailer.convite_expirado para evitar NoMethodError devido ao Bug #3
    allow(TransferMailer).to receive(:convite_expirado).and_return(double(deliver_later: true))
  end

  it "expira a transferência pendente e a transferência quando o prazo passou" do
    described_class.perform_now(pending.id)

    expect(pending.reload.status).to eq("expirado")
    expect(transfer.reload.status).to eq("expirado")
  end
end
