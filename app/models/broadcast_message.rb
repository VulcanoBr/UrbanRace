class BroadcastMessage < ApplicationRecord
  belongs_to :event
  
  # Define que o 'sender' é na verdade um objeto da classe Organizer
  belongs_to :sender, class_name: "Organizer"
  
  belongs_to :volunteer_station, optional: true

  # Padrão Rails 8.1 para Enums
  enum :categoria, { 
    informativo: "info", 
    alerta: "warning", 
    urgente: "critical" 
  }, default: "info"

  validates :titulo, :corpo, :categoria, presence: true

  def critical?
    urgente?
  end
end