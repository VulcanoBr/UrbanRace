# app/models/timing.rb
#
# Armazena o tempo bruto de cada atleta em cada waypoint.
# pace_km é decimal (segundos por km) para facilitar cálculos.
# A conversão para "MM:SS" é feita no ResultCalculatorService.
class Timing < ApplicationRecord
  belongs_to :registration
  belongs_to :waypoint

  # ── Validações ────────────────────────────────────────────────────────
  validates :chip_time,   presence: true
  validates :gun_time,    presence: true
  validates :waypoint_id, uniqueness: { scope: :registration_id,
                                        message: "já existe tempo para este atleta neste ponto" }
  validate  :chip_time_posterior_ao_gun_time

  # ── Escopos ───────────────────────────────────────────────────────────
  scope :por_tempo,   -> { order(chip_time: :asc) }
  scope :chegadas,    -> { joins(:waypoint).where(waypoints: { eh_chegada: true }) }
  scope :largadas,    -> { joins(:waypoint).where(waypoints: { eh_largada: true }) }
  scope :do_evento,   ->(event_id) {
    joins(registration: :event).where(events: { id: event_id })
  }

  # ── Métodos de instância ──────────────────────────────────────────────

  # Tempo líquido em segundos (chip_time - gun_time)
  def tempo_liquido_segundos
    return nil unless chip_time && gun_time
    (chip_time - gun_time).to_i
  end

  # Pace como "MM:SS" para exibição
  def pace_formatado
    return nil if pace_km.nil? || pace_km.to_f <= 0

    total = pace_km.to_f
    min   = (total / 60).to_i
    seg   = (total % 60).to_i
    format("%02d:%02d", min, seg)
  end

  private

  def chip_time_posterior_ao_gun_time
    return unless chip_time && gun_time

    if chip_time <= gun_time
      errors.add(:chip_time, "deve ser posterior ao gun_time (#{gun_time.strftime("%H:%M:%S")})")
    end
  end
end
