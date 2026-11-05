# app/services/operation/status_cleanup_service.rb
class Operation::StatusCleanupService
  def self.process_absent_athletes(event)
    # DNS: Inscritos confirmados que não fizeram check-in nem registro de tempo
    event.registrations.confirmado.each do |reg|
      if reg.athlete_checkins.empty? && reg.timings.empty?
        reg.update!(status: "dns") # Did Not Start
      elsif reg.timings.any? && !reg.timings.joins(:waypoint).exists?(waypoints: { eh_chegada: true })
        reg.update!(status: "dnf") # Did Not Finish
      end
    end
  end
end