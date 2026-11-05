class Athletes::RegistrationMailer < ApplicationMailer
  default from: "comunicacao@urbanrace.com.br"

  def kit_delivered_confirmation(registration)
    @registration = registration
    @athlete = registration.athlete
    @event = registration.event

    mail(
      to: @athlete.email_address,
      subject: "✅ Kit Retirado! Tudo pronto para a sua largada no #{@event.nome}"
    )
  end
end