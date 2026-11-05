# app/models/result.rb
class Result < ApplicationRecord
  belongs_to :registration
  belongs_to :event
  has_one :certificate, dependent: :destroy
  has_many :nps_responses

  # ── Constantes ────────────────────────────────────────────────────────
  STATUS_FINALIZACAO = %w[concluido dns dnf dsq].freeze

  TEMPO_HMS_REGEX = /\A\d{2}:\d{2}:\d{2}\z/
  TEMPO_MS_REGEX  = /\A\d{1,3}:\d{2}\z/

  # ── Validações ────────────────────────────────────────────────────────
  validates :registration_id, :event_id, presence: true

  validates :status_finalizacao,
            presence: true,
            inclusion: { in: STATUS_FINALIZACAO }

  validates :tempo_liquido,
            presence: true,
            format: {
              with: /\A\d{2}:\d{2}:\d{2}\z/,
              message: "deve estar no formato HH:MM:SS"
            },
            if: -> { status_finalizacao == "concluido" }

  validates :tempo_bruto,
            format: {
              with: /\A\d{2}:\d{2}:\d{2}\z/,
              message: "deve estar no formato HH:MM:SS"
            },
            allow_blank: true

  # ── Escopos ───────────────────────────────────────────────────────────
  scope :homologados, -> { where(homologado: true) }
  scope :pendentes, -> { where(homologado: false) }
  scope :concluidos, -> { where(status_finalizacao: "concluido") }
  scope :por_posicao, -> { order(:posicao_geral) }
  scope :por_evento, ->(event_id) { where(event_id: event_id) }

  # ── Callbacks ─────────────────────────────────────────────────────────
  before_validation :sync_event_from_registration
  before_validation :normalizar_tempos
  before_save :calcular_pace_medio

  # ── Métodos de instância ──────────────────────────────────────────────

  def certificado_geravel?
    homologado?
  end

  def finisher?
    status_finalizacao == "concluido"
  end

  # Converte tempo_liquido (HH:MM:SS) para total de segundos
  def tempo_liquido_em_segundos
    hms_para_segundos(tempo_liquido)
  end

  # Retorna pace_medio como string "MM:SS /km" para exibição
  def pace_formatado
    return nil if pace_medio.blank?

    "#{pace_medio}/km"
  end

  def homologar!
    return false if homologado?

    update!(
      homologado: true,
      homologado_em: Time.current
    )

    Certificates::GenerateSingleJob.perform_later(id)

    true
  end

  private

  def sync_event_from_registration
    self.event ||= registration&.event
  end

  def normalizar_tempos
    self.tempo_liquido = normalizar_tempo(tempo_liquido)
    self.tempo_bruto   = normalizar_tempo(tempo_bruto)
  end

  def normalizar_tempo(valor)
    return valor if valor.blank?
    return valor if valor.match?(TEMPO_HMS_REGEX)

    if valor.match?(TEMPO_MS_REGEX)
      minutos, segundos = valor.split(":").map(&:to_i)

      horas = minutos / 60
      minutos_restantes = minutos % 60

      format("%02d:%02d:%02d", horas, minutos_restantes, segundos)
    else
      valor
    end
  end

  # Recalcula pace_medio a partir de tempo_liquido e distância da inscrição.
  # Armazena no formato "MM:SS".
  def calcular_pace_medio
    return if tempo_liquido.blank?
    return unless registration&.distance

    distancia_km = registration.distance.km.to_f
    return unless distancia_km > 0

    total_segundos = hms_para_segundos(tempo_liquido)
    return unless total_segundos

    segundos_por_km = total_segundos / distancia_km

    minutos = (segundos_por_km / 60).to_i
    segundos = (segundos_por_km % 60).to_i

    self.pace_medio = format("%02d:%02d", minutos, segundos)
  end

  def hms_para_segundos(hms)
    return nil unless hms&.match?(TEMPO_HMS_REGEX)

    partes = hms.split(":").map(&:to_i)

    partes[0] * 3600 +
      partes[1] * 60 +
      partes[2]
  end
end