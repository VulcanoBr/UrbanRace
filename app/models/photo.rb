class Photo < ApplicationRecord
  belongs_to :event

  # N:N com registrations via tabela join
  has_many :photo_registrations, dependent: :destroy
  has_many :registrations, through: :photo_registrations

  has_one_attached :arquivo

  # Tipos de foto:
  # "atleta"  → foto onde a IA tentará identificar dorsais
  # "evento"  → foto geral do evento (bastidores, largada, chegada, pódio)
  TIPOS = %w[atleta evento].freeze

  validates :tipo, inclusion: { in: TIPOS }

  # ── Escopos ──────────────────────────────────────────────────────────────
  scope :identificadas,   -> { where(reconhecido_ia: true) }
  scope :pendentes,       -> { where(reconhecido_ia: false) }
  scope :tipo_atleta,     -> { where(tipo: "atleta") }
  scope :tipo_evento,     -> { where(tipo: "evento") }
  scope :com_arquivo, -> { joins(:arquivo_attachment) }

  # ── Métodos de instância ─────────────────────────────────────────────────

  # Retorna os dorsais detectados nesta foto (pode ser mais de um)
  def dorsais_detectados
    registrations.pluck(:numero_dorsal)
  end

  # Verifica se um determinado atleta (registration) está nesta foto
  def contem_atleta?(registration)
    registrations.exists?(registration.id)
  end

  # Foto de evento (sem atleta associado, sem processamento de IA)
  def foto_evento?
    tipo == "evento"
  end

  # Foto de atleta (passa por processamento de IA)
  def foto_atleta?
    tipo == "atleta"
  end
end
