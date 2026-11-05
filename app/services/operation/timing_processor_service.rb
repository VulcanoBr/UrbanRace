class Operation::TimingProcessorService
  attr_reader :registration, :waypoint, :raw_time, :gun_time

  def initialize(registration: nil, waypoint:, raw_time: nil, gun_time: nil)
    @registration = registration
    @waypoint     = waypoint
    @raw_time     = raw_time
    @gun_time     = gun_time
  end

  def processar
    raise ArgumentError, "registration é obrigatório" unless registration
    raise ArgumentError, "raw_time é obrigatório"     unless raw_time
    raise ArgumentError, "gun_time é obrigatório"     unless gun_time

    timing = Timing.find_or_initialize_by(
      registration: registration,
      waypoint:     waypoint
    )

    chip_time_seconds = (raw_time - gun_time).to_f

    timing.assign_attributes(
      gun_time:  gun_time,
      chip_time: raw_time,
      pace_km:   calcular_pace(chip_time: chip_time_seconds, km: waypoint.km)
    )

    timing.save!

    broadcast_ranking_update(registration.event)

    timing
  end

  def processar_lote(payload)
    payload.each do |item|
      reg = registration_por_dorsal(item[:dorsal])
      next unless reg

      self.class.new(
        registration: reg,
        waypoint:     waypoint,
        raw_time:     item[:raw_time],
        gun_time:     gun_time
      ).processar
    end
  end

  # chip_time em segundos (Numeric), km em km (Numeric)
  def calcular_pace(chip_time:, km:)
    return nil if chip_time.nil?
    return nil if km.nil? || km.to_f <= 0

    (chip_time.to_f / km.to_f).round(2)
  end

  private

  def registration_por_dorsal(dorsal)
    Registration.find_by(
      event:         waypoint.route.event,
      numero_dorsal: dorsal
    )
  end

  def broadcast_ranking_update(event)
    Turbo::StreamsChannel.broadcast_replace_to(
      "ranking_event_#{event.id}",
      target:  "live_ranking_list",
      partial: "organizer/results/ranking_table",
      locals:  {
        results: event.results.order(:posicao_geral).limit(10)
      }
    )
  end
end