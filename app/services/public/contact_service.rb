# app/services/public/contact_service.rb
class Public::ContactService
  def self.call(form)
    # Dispara o mailer passando os parâmetros do formulário
    # .deliver_later usa o Solid Queue automaticamente no Rails 8
    Public::ContactMailer.with(
      nome:     form.nome,
      email:    form.email,
      assunto:  form.assunto,
      mensagem: form.mensagem
    ).new_message.deliver_later
    
    true
  rescue => e
    Rails.logger.error "[ContactService Error] #{e.message}"
    false
  end
end