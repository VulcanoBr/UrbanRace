# frozen_string_literal: true

require "rails_helper"

RSpec.describe Organizer::EventScopeService, type: :service do
  let(:organizer) { create(:organizer) }
  let!(:event1)   { create(:event, organizer: organizer, data_largada: 2.months.from_now.to_date) }
  let!(:event2)   { create(:event, organizer: organizer, data_largada: 3.months.from_now.to_date) }
  let(:other_org) { create(:organizer) }
  let!(:other_ev) { create(:event, organizer: other_org) }

  subject(:service) { described_class.new(organizer) }

  describe "#active_event" do
    it "retorna o evento mais recente por data_largada" do
      expect(service.active_event).to eq(event2)
    end

    it "retorna apenas eventos do organizador" do
      expect(service.active_event).not_to eq(other_ev)
    end

    it "retorna nil quando organizador não tem eventos" do
      novo_org = create(:organizer)
      expect(described_class.new(novo_org).active_event).to be_nil
    end
  end

  describe "#find_by_slug" do
    it "encontra evento pelo slug_url" do
      expect(service.find_by_slug(event1.slug_url)).to eq(event1)
    end

    it "não encontra evento de outro organizador" do
      expect(service.find_by_slug(other_ev.slug_url)).to be_nil
    end

    it "levanta RecordNotFound para slug inexistente" do
      expect { service.find_by_slug("slug-inexistente") }.to raise_error(ActiveRecord::RecordNotFound)
    end

    # REGRESSÃO: o redirect após update usava id numérico como parâmetro
    # Garantir que find_by_slug falha com inteiro (id) e só funciona com slug string
    it "não encontra evento passando id numérico como string (regressão)" do
      expect(service.find_by_slug(event1.id.to_s)).to be_nil
    end
  end

  describe "#all_events" do
    it "retorna todos os eventos do organizador" do
      expect(service.all_events).to contain_exactly(event1, event2)
    end

    it "exclui eventos de outros organizadores" do
      expect(service.all_events).not_to include(other_ev)
    end
  end
end
