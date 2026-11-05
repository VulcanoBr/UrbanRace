class Supplier < ApplicationRecord
  has_many :supplier_contracts
  validates :razao_social, :cnpj, presence: true
  validates :cnpj, uniqueness: true
   validates :email_contato, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
end