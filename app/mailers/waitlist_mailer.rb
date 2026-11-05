class WaitlistMailer < ApplicationMailer
  def entrada_confirmada(waitlist)
    @waitlist = waitlist
    @athlete  = waitlist.athlete
    @event    = waitlist.event
    @category = waitlist.category
    @posicao  = waitlist.posicao

    mail(
      to:      @athlete.email_address,
      subject: "[#{@event.nome}] Você está na lista de espera — posição #{@posicao}"
    )
  end

  def vaga_disponivel(waitlist)
    @waitlist = waitlist
    @athlete  = waitlist.athlete
    @event    = waitlist.event
    @category = waitlist.category
    # Link com prazo — o atleta tem 48h para se inscrever
    @inscricao_url = new_public_registration_url(
      slug:        @event.slug_url,
      distance_id: @category.distance_id
    )

    mail(
      to:      @athlete.email_address,
      subject: "[#{@event.nome}] 🎉 Uma vaga abriu para você!"
    )
  end
end