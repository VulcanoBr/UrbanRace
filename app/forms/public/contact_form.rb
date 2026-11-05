class Public::ContactForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :nome, :string
  attribute :email, :string
  attribute :assunto, :string
  attribute :mensagem, :string

  validates :nome, :email, :assunto, :mensagem, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :mensagem, length: { minimum: 10 }

  def submit
    return false unless valid?

    # Aqui chamamos o Service para processar o envio
    Public::ContactService.call(self)
  end
end