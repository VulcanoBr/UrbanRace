# frozen_string_literal: true

class EmailCampaign < ApplicationRecord
  belongs_to :event

  SEGMENTOS = %w[todos pagos pendentes espera].freeze

  validates :event, presence: true
  validates :assunto, presence: true
  validates :segmento, presence: true, inclusion: { in: SEGMENTOS }

  validates :enviados,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :abertos,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :clicados,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  scope :recentes, -> { order(created_at: :desc) }
  scope :enviadas, -> { where.not(enviado_em: nil) }
  scope :pendentes, -> { where(enviado_em: nil) }
  scope :do_segmento, ->(segmento) { where(segmento: segmento) }

  def enviada?
    enviado_em.present?
  end

  def pendente?
    enviado_em.nil?
  end

  def total_enviados
    enviados.to_i
  end

  def total_abertos
    abertos.to_i
  end

  def total_clicados
    clicados.to_i
  end

  def taxa_abertura
    return 0.0 if total_enviados.zero?

    (total_abertos.to_f / total_enviados * 100).round(2)
  end

  def taxa_cliques
    return 0.0 if total_enviados.zero?

    (total_clicados.to_f / total_enviados * 100).round(2)
  end
end