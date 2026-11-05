class Incident < ApplicationRecord
  belongs_to :event
  belongs_to :registration, optional: true # Pode ser um espectador (sem inscrição)
  belongs_to :responsavel, class_name: 'Organizer', foreign_key: :organizer_id

  enum :tipo, { queda: "fall", mal_estar: "faint", trauma: "injury", cardiaco: "cardiac", outro: "other" }
  enum :gravidade, { baixa: "low", media: "medium", alta: "high", critica: "critical" }
  enum :status, { aberto: "open", em_atendimento: "resolving", fechado: "closed" }, default: "open"

  validates :tipo, :gravidade, :km_local, :ocorrida_em, presence: true

  before_validation :set_default_ocorrida_em

  private

  def set_default_ocorrida_em
    self.ocorrida_em ||= Time.current
  end
  
end