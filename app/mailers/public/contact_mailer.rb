class Public::ContactMailer < ApplicationMailer
  # O e-mail padrão de quem envia (configurado no seu mailer_layout ou aqui)
  default from: "no-reply@urbanrace.com"

  def new_message
    @nome     = params[:nome]
    @email    = params[:email]
    @assunto  = params[:assunto]
    @mensagem = params[:mensagem]

    mail(
      to: "contato@urbanrace.com",
      subject: "URBANRACE - Novo Contato: #{@assunto}",
      reply_to: @email # Permite que você responda diretamente ao atleta
    )
  end
end