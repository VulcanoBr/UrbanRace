class License < ApplicationRecord
  belongs_to :event
  
  has_one_attached :documento_pdf

  enum :status, { 
    pendente: 'pending', 
    solicitado: 'requested', 
    aprovado: 'approved', 
    vencido: 'expired' 
  }, default: :pendente
  
  scope :criticas, -> { where(status: ['pending', 'expired']).where('prazo_aprovacao <= ?', 7.days.from_now) }

  validates :tipo, :orgao, :prazo_aprovacao, presence: true
end