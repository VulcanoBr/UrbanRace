require "rails_helper"

RSpec.describe Operation::TimingProcessorService, type: :service do
  let(:organizer)    { create(:organizer) }
  let(:event)        { create(:event, :active, organizer: organizer) }
  let(:distance)     { create(:distance, :dez_km, event: event) }
  let(:athlete)      { create(:athlete) }
  let(:registration) { create(:registration, :confirmed, event: event, distance: distance) }
  let(:route) { create(:route, event: event, distance: distance) }
  let(:waypoint)     { create(:waypoint, route: route, km: 5.0) }
  let(:finish_wp)    { create(:waypoint, route: route, km: 10.0) }

  let(:gun_time)     { Time.zone.parse("2026-09-04 06:00:00") }
  let(:raw_time_5k)  { gun_time + 25.minutes }
  let(:raw_time_10k) { gun_time + 55.minutes + 30.seconds }

  # Stub do broadcast para não depender da partial HTML nos specs de service
  before do
    allow(Turbo::StreamsChannel).to receive(:broadcast_replace_to)
  end

  describe "#calcular_pace" do
    subject(:svc) { described_class.new(registration: registration, waypoint: waypoint) }

    context "com tempo e km válidos" do
      it "calcula pace em segundos por km" do
        # 25 min = 1500 s para 5 km → 300 s/km
        pace = svc.calcular_pace(chip_time: 1500, km: 5.0)
        expect(pace).to eq(300.0)
      end

      it "arredonda pace com 2 casas decimais" do
        pace = svc.calcular_pace(chip_time: 3333, km: 10.0)
        expect(pace).to eq((3333.0 / 10.0).round(2))
      end
    end

    context "com km zero ou nil" do
      it "retorna nil para km zero" do
        expect(svc.calcular_pace(chip_time: 3600, km: 0)).to be_nil
      end

      it "retorna nil para km nil" do
        expect(svc.calcular_pace(chip_time: 3600, km: nil)).to be_nil
      end
    end

    context "com chip_time nil" do
      it "retorna nil" do
        expect(svc.calcular_pace(chip_time: nil, km: 5.0)).to be_nil
      end
    end
  end

  describe "#processar" do
    subject(:svc) do
      described_class.new(
        registration: registration,
        waypoint:     finish_wp,
        raw_time:     raw_time_10k,
        gun_time:     gun_time
      )
    end

    it "cria um timing_record" do
      expect { svc.processar }.to change(Timing, :count).by(1)
    end

    it "calcula chip_time corretamente" do
      svc.processar
      record = Timing.last
      # chip_time no banco é o raw_time (datetime absoluto)
      expect(record.chip_time).to eq(raw_time_10k)
    end

    it "salva o pace_km calculado" do
      svc.processar
      expect(Timing.last.pace_km).to be > 0
    end

    it "associa ao registration correto" do
      svc.processar
      expect(Timing.last.registration).to eq(registration)
    end

    it "associa ao waypoint correto" do
      svc.processar
      expect(Timing.last.waypoint).to eq(finish_wp)
    end

    context "com registro duplicado para o mesmo waypoint" do
      before { svc.processar }

      it "não cria duplicata" do
        expect { svc.processar }.not_to change(Timing, :count)
      end

      it "retorna o registro existente" do
        resultado = svc.processar
        expect(resultado).to eq(
          Timing.find_by(registration: registration, waypoint: finish_wp)
        )
      end
    end
  end

  describe "#processar_lote" do
    let(:registrations) do
      create_list(:registration, 3, :confirmed, event: event, distance: distance)
    end

    let(:payload) do
      registrations.map.with_index do |reg, i|
        { dorsal: reg.numero_dorsal, raw_time: gun_time + (55 + i * 2).minutes }
      end
    end

    subject(:svc) { described_class.new(waypoint: finish_wp, gun_time: gun_time) }

    it "processa todos os registros do lote" do
      expect { svc.processar_lote(payload) }.to change(Timing, :count).by(3)
    end

    it "ignora dorsais não encontrados sem levantar exceção" do
      payload_invalido = payload + [{ dorsal: 99999, raw_time: gun_time + 1.hour }]
      expect { svc.processar_lote(payload_invalido) }.not_to raise_error
      expect(Timing.count).to eq(3)
    end
  end
end