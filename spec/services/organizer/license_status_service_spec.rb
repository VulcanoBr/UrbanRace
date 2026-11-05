# spec/services/organizer/license_status_service_spec.rb
require "rails_helper"

RSpec.describe Organizer::LicenseStatusService, type: :service do
  let(:event) { create(:event) }

  describe "#check_all" do
    let!(:aprovada)    { create(:license, :approved,       event: event) }
    let!(:vencendo)    { create(:license, :expiring_soon,  event: event) }
    let!(:vencida)     { create(:license, :expired,        event: event) }
    let!(:pendente_ok) { create(:license, event: event,
                                prazo_aprovacao: 30.days.from_now.to_date) }

    subject(:resultado) { described_class.new(event).check_all }

    it "identifica licenças vencendo em breve" do
      expect(resultado[:expiring_soon]).to include(vencendo)
    end

    it "identifica licenças vencidas" do
      expect(resultado[:expired]).to include(vencida)
    end

    it "não inclui licenças aprovadas nos alertas" do
      expect(resultado[:expiring_soon]).not_to include(aprovada)
      expect(resultado[:expired]).not_to include(aprovada)
    end

    it "retorna contagem correta" do
      expect(resultado[:total_alerts]).to be >= 2
    end
  end

  describe "#needs_alert?" do
    it "true para licença vencendo dentro do prazo de alerta" do
      license = build(:license, :expiring_soon)
      expect(described_class.new(event).needs_alert?(license, dias: 7)).to be true
    end

    it "false para licença com prazo confortável" do
      license = build(:license, prazo_aprovacao: 30.days.from_now.to_date)
      expect(described_class.new(event).needs_alert?(license, dias: 7)).to be false
    end

    it "true para licença já vencida" do
      license = build(:license, :expired)
      expect(described_class.new(event).needs_alert?(license)).to be true
    end
  end
end