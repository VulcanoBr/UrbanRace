class Public::WaitlistService
  def self.add_athlete(athlete:, category:, lot:)
    # Evita duplicata silenciosamente
    return if Waitlist.exists?(
      athlete_id: athlete.id,
      category_id: category.id,
      status: "aguardando"
    )

    last_position = Waitlist
                      .where(category_id: category.id, status: "aguardando")
                      .maximum(:posicao) || 0

    waitlist = Waitlist.create!(
      athlete:      athlete,
      category:     category,
      distance:     category.distance,
      event:        category.distance.event,
      lot:          lot,
      posicao:      last_position + 1,
      status:       "aguardando",
      data_entrada: Time.current
    )

    WaitlistMailer.entrada_confirmada(waitlist).deliver_later
    waitlist
  end
end