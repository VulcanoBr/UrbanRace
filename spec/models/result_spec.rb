# frozen_string_literal: true

require "rails_helper"

RSpec.describe Result, type: :model do
  describe "validações" do
    it { is_expected.to validate_presence_of(:registration_id) }
    it { is_expected.to validate_presence_of(:event_id) }
    it { is_expected.to validate_presence_of(:status_finalizacao) }

    it "exige tempo_liquido quando status_finalizacao for concluido" do
      registration = create(:registration)   # ← adicionar isso

      result = build(
        :result,
        registration:       registration,    # ← passar explicitamente
        status_finalizacao: "concluido",
        tempo_liquido:      nil
      )

      expect(result).not_to be_valid
      expect(result.errors[:tempo_liquido])
        .to include("não pode ficar em branco")
    end
  end

  describe "callback calculate_pace_medio" do
    let(:event) { create(:event) }

    let(:distance) do
      create(
        :distance,
        event: event,
        km: 10.0
      )
    end

    let(:registration) do
      create(
        :registration,
        event: event,
        distance: distance
      )
    end

    it "calcula pace médio no formato MM:SS a partir do tempo líquido" do
      result = build(
        :result,
        registration: registration,
        tempo_liquido: "00:45:00"
      )

      result.save!

      expect(result.pace_medio).to eq("04:30")
    end

    it "normaliza MM:SS para HH:MM:SS e calcula o pace" do
      result = build(
        :result,
        registration: registration,
        tempo_liquido: "45:00"
      )

      result.save!

      expect(result.tempo_liquido).to eq("00:45:00")
      expect(result.pace_medio).to eq("04:30")
    end

    it "normaliza MM:SS acima de uma hora" do
      result = build(
        :result,
        registration: registration,
        tempo_liquido: "90:00"
      )

      result.save!

      expect(result.tempo_liquido).to eq("01:30:00")
      expect(result.pace_medio).to eq("09:00")
    end

    it "rejeita formato de tempo inválido" do
      result = build(
        :result,
        registration: registration,
        tempo_liquido: "45"
      )

      expect(result).not_to be_valid

      expect(result.errors[:tempo_liquido])
        .to include("deve estar no formato HH:MM:SS")
    end
  end
end