class EventRankingService

  def initialize(event)
    @event = event
  end

  def ranking(distance:, category:)

    Result
      .homologados
      .joins(
        registration: [
          :athlete,
          :distance,
          :category
        ]
      )
      .where(
        event: @event,
        registrations: {
          distance_id: distance.id,
          category_id: category.id
        }
      )
      .order(:posicao_categoria)
      .limit(10)
      .select(
        <<~SQL
          results.*,
          athletes.nome AS athlete_name,
          athletes.sexo,
          registrations.numero_dorsal
        SQL
      )

  end

end