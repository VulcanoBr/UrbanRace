class Athlete < ApplicationRecord
  has_secure_password
  has_many :sessions,      as: :user, dependent: :destroy
  has_many :registrations, dependent: :destroy
  has_many :waitlists,     dependent: :destroy
  has_many :certificates,  dependent: :destroy
  has_many :nps_responses, dependent: :destroy

  validates :email_address, presence: true, uniqueness: true,
                             format: { with: URI::MailTo::EMAIL_REGEXP }

  # ── CPF: valida o formato apenas em registros NÃO anonimizados ──────────
  validates :cpf, presence: true, uniqueness: true
  validates :cpf, cpf: true, unless: :anonimizado?

  validates :nome,      presence: true
  validates :nascimento, presence: true
  validates :sexo, presence: true, inclusion: { in: %w[masculino feminino], message: "deve ser Masculino ou Feminino" }

  normalizes :email_address, with: ->(e)  { e.strip.downcase }
  normalizes :telefone,      with: ->(t)  { t.to_s.gsub(/\D/, "") }

  scope :search, lambda { |term|
    termo = term.to_s.strip

    if termo.present?
      padrao = "%#{sanitize_sql_like(termo)}%"
      cpf_termo = termo.gsub(/\D/, "")

      condicoes = [
        "athletes.nome ILIKE :termo",
        "athletes.email_address ILIKE :termo"
      ]

      valores = { termo: padrao }

      if cpf_termo.present?
        condicoes << "athletes.cpf LIKE :cpf"
        valores[:cpf] = "%#{sanitize_sql_like(cpf_termo)}%"
      end

      where(condicoes.join(" OR "), valores)
    end
  }

  # ── normalizes :cpf só remove não-dígitos em CPFs reais ─────────────────
  # Para valores LGPD-DEL-* preservamos o valor intacto.
  normalizes :cpf, with: ->(cpf) {
    cpf.start_with?(Athletes::PrivacyService::ANONIMIZADO_PREFIX) ?
      cpf :
      cpf.to_s.gsub(/\D/, "")
  }

  generates_token_for :password_reset, expires_in: 15.minutes do
    password_digest
  end

  def display_name = nome
  def anonimizado? = cpf.to_s.start_with?(Athletes::PrivacyService::ANONIMIZADO_PREFIX)
end