# app/mailers/registrations_mailer.rb
#
# Mailer para comunicações relacionadas a inscrições.
# Usa o padrão de params (mailer params) adotado no projeto:
#
#   RegistrationsMailer
#     .with(registration: registration, kind: "48h")
#     .kit_pickup_reminder
#     .deliver_later
#
class RegistrationsMailer < ApplicationMailer
  # Lembrete de retirada de kit
  #
  # params esperados:
  #   :registration  [Registration] — inscrição confirmada
  #   :kind          [String]       — "48h" | "24h"
  def kit_pickup_reminder
    @registration = params[:registration]
    @kind         = params[:kind]
    @athlete      = @registration.athlete
    @event        = @registration.event

    @hours_label  = @kind == "48h" ? "48 horas" : "24 horas"
    @urgency      = @kind == "24h"   # true → e-mail com tom mais urgente

    mail(
      to:      @athlete.email_address,
      subject: subject_for_kind
    )
  end

  private

  def subject_for_kind
    event_name = @event.nome
    if @kind == "48h"
      "[#{event_name}] Retire seu kit — faltam 48 horas para a largada!"
    else
      "[#{event_name}] URGENTE: retire seu kit hoje — largada amanhã!"
    end
  end
end
