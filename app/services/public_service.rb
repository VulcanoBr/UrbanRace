# app/services/public/waitlist_service.rb
class PublicService
  def self.add_athlete(athlete_id:, category_id:)
    last_position = Waitlist.where(category_id: category_id).maximum(:posicao) || 0
    
    Waitlist.create!(
      athlete_id: athlete_id,
      category_id: category_id,
      posicao: last_position + 1,
      status: "aguardando",
      data_entrada: Time.current
    )
  end
end