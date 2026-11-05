class EventCancellationMailer < ApplicationMailer

  # E-mail principal: avisa o atleta que o evento foi cancelado
  def notify_athlete
    @registration  = params[:registration]
    @athlete       = @registration.athlete
    @event         = @registration.event
    @refund_status = params[:refund_status]   # :not_charged | :refunded_automatically | :manual_refund
    @payment       = @registration.payment    # pode ser nil

    mail(
      to:      @athlete.email_address,
      subject: subject_for(@refund_status)
    )
  end

  # E-mail de confirmação quando o estorno automático deu certo
  def refund_confirmed(registration)
    @registration = registration
    @athlete      = registration.athlete
    @event        = registration.event
    @amount       = registration.refunded_amount

    mail(
      to:      @athlete.email_address,
      subject: "✅ Reembolso confirmado — #{@event.nome}"
    )
  end

  # E-mail quando o estorno precisa ser feito manualmente pelo organizador
  def manual_refund_required(registration)
    @registration = registration
    @athlete      = registration.athlete
    @event        = registration.event
    @organizer    = @event.organizer

    # Notifica o atleta
    mail(
      to:      @athlete.email_address,
      subject: "💰 Reembolso em processamento — #{@event.nome}"
    )
  end

  private

  def subject_for(refund_status)
    case refund_status
    when :not_charged           then "❌ Evento cancelado: #{@event.nome}"
    when :refunded_automatically then "✅ Reembolso confirmado — #{@event.nome}"
    when :manual_refund         then "💰 Reembolso em processamento — #{@event.nome}"
    else                             "❌ Evento cancelado: #{@event.nome}"
    end
  end
end