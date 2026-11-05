require "rails_helper"

RSpec.describe FinalizeEventStatusJob, type: :job do
  let(:organizer) { create(:organizer) }

  describe "#perform" do
    let!(:ativo_passado) do
      create(:event, :active, organizer: organizer, data_largada: 2.days.ago.to_date)
    end
    let!(:ativo_futuro) do
      create(:event, :active, organizer: organizer, data_largada: 10.days.from_now.to_date)
    end
    let!(:publicado_passado) do
      create(:event, :published, organizer: organizer, data_largada: 1.day.ago.to_date)
    end

    before { described_class.perform_now }

    it "finaliza eventos ativos cuja data já passou" do
      expect(ativo_passado.reload).to have_attributes(status: "finished")
    end

    it "não altera eventos ativos ainda no futuro" do
      expect(ativo_futuro.reload).to have_attributes(status: "active")
    end

    it "pode ser enfileirado" do
      expect { described_class.perform_later }.to have_enqueued_job(described_class)
    end
  end
end
