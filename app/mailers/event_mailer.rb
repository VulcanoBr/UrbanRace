# app/mailers/event_mailer.rb
class EventMailer < ApplicationMailer

  # ── Evento cancelado ─────────────────────────────────────────────────────
  #
  # refund_status:
  #   :not_charged            — pagamento pendente, nunca foi cobrado
  #   :refunded_automatically — estorno processado automaticamente pelo gateway
  #   :manual_refund          — boleto ou sem gateway_id; devolução manual necessária
  #
  def event_cancelled(event:, registration:, refund_status:)
    @event         = event
    @registration  = registration
    @athlete       = registration.athlete
    @refund_status = refund_status
    @payment       = registration.payment

    mail(
      to:      @athlete.email,
      subject: "❌ Evento cancelado: #{@event.nome}"
    )
  end

  # ── Evento finalizado ────────────────────────────────────────────────────

  def event_finished(event:, registration:)
    @event        = event
    @registration = registration
    @athlete      = registration.athlete

    mail(
      to:      @athlete.email,
      subject: "🏅 #{@event.nome} foi finalizado — veja seus resultados!"
    )
  end
end