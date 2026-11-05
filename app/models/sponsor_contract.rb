class SponsorContract < ApplicationRecord
  belongs_to :sponsor
  belongs_to :event

  has_one_attached :arquivo_pdf

  enum :status, { negociacao: 'negotiating', assinado: 'signed', concluido: 'completed', cancelado: 'cancelled' }
end