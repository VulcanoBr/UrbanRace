class Sponsor < ApplicationRecord

  has_many :sponsor_contracts
  
  has_one_attached :logo

  validates :nome, :cnpj, presence: true
  validates :cnpj, uniqueness: true

  # Rails 8: Normalização de dados
  normalizes :email_contato, with: ->(email) { email.strip.downcase }
  normalizes :website, with: ->(url) { url.strip.downcase.gsub(%r{^https?://}, "") }

  scope :ativos, -> { where(ativo: true) }
  
  def status_class
    ativo ? "bg-green-50 text-green-700 ring-green-600/20" : "bg-red-50 text-red-700 ring-red-600/20"
  end
end