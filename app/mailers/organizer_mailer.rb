class OrganizerMailer < ApplicationMailer
  def license_alert(organizer:, event:, license:, days:)
      @organizer = organizer
      @event     = event
      @license   = license
      @days      = days

      urgency = case days
                when 7  then "🔴 URGENTE"
                when 15 then "🟠 Atenção"
                else         "🟡 Aviso"
                end

      mail(
        to:      @organizer.email_address,
        subject: "[#{urgency}] #{@event.nome} — Licença vence em #{@days} dias"
      )
  end  
end