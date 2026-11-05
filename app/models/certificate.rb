# frozen_string_literal: true

class Certificate < ApplicationRecord
  belongs_to :result
  belongs_to :athlete

  has_one_attached :arquivo_pdf

  validates :result, :athlete, presence: true
  validates :qr_code_hash, presence: true, uniqueness: true

  validates :result_id, uniqueness: true

  scope :recentes, -> { order(created_at: :desc) }
  scope :gerados, -> { where.not(gerado_em: nil) }

  delegate :event, to: :result

  def pdf_disponivel?
    arquivo_pdf.attached?
  end

  def gerado?
    gerado_em.present? && arquivo_pdf.attached?
  end

  def validavel?
    gerado? && result&.homologado?
  end
end
