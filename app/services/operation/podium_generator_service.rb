# app/services/operation/podium_generator_service.rb
class Operation::PodiumGeneratorservice
  def self.generate(event, category)
    # Busca os top 3 ou 5 baseados no tempo líquido homologado ou preliminar
    event.registrations
         .confirmado
         .joins(:timings)
         .where(category: category)
         .where(timings: { waypoint: event.routes.find_by(distance: category.distance).waypoints.chegada })
         .order('timings.chip_time ASC')
         .limit(5)
  end
end