# app/mailers/registration_mailer.rb
class RegistrationMailer < ApplicationMailer
  default from: 'contato@urbanrace.com'

  def confirmation_email
    @registration = params[:registration]
    @athlete = @registration.athlete
    @event = @registration.event

    mail(
      to: @athlete.email_address,
      subject: "Inscrição Confirmada! - #{@event.nome} - Dorsal ##{@registration.numero_dorsal}"
    )
  end
end