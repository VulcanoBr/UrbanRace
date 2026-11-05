# frozen_string_literal: true
# spec/jobs/update_lots_status_job_spec.rb
require "rails_helper"

RSpec.describe UpdateLotsStatusJob, type: :job do
  it "inativa lotes que passaram da data de encerramento" do
    lot = create(:lot, :passado, status: "active")

    described_class.perform_now

    expect(lot.reload.status).to eq("inativo")  # chave do enum, não valor do banco
  end

  it "ativa lotes inativos que alcançaram a data de abertura" do
    lot = create(:lot, status: "inactive", abertura: 1.hour.ago, encerramento: 10.days.from_now)

    described_class.perform_now

    expect(lot.reload.status).to eq("ativo")  # chave do enum
  end
end
