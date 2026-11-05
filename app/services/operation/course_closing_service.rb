# app/services/operation/course_closing_service.rb
class Operation::CourseClosingService
  def self.close_point(waypoint_id, organizer_id)
    waypoint = Waypoint.find(waypoint_id)
    event = waypoint.route.event

    return false unless waypoint.aberto?

    Waypoint.transaction do
      # 1. Fecha o ponto
      waypoint.update!(
        closed_at: Time.current,
        closed_by_id: organizer_id
      )

      # 2. Notifica o Command Center e os Voluntários via Solid Cable
      broadcast_closure(waypoint)

      # 3. Se for a chegada, finaliza o evento e libera resultados preliminares
      if waypoint.eh_chegada?
        finalize_event(event)
      end
    end
    true
  end

  private

  def self.broadcast_closure(waypoint)
    Turbo::StreamsChannel.broadcast_replace_to(
      "event_#{waypoint.route.event_id}_course_status",
      target: "waypoint_#{waypoint.id}_status",
      partial: "operation/course_closings/waypoint_status",
      locals: { waypoint: waypoint }
    )
  end

  def self.finalize_event(event)
    event.update!(status: :finished)
    
    # Executa a limpeza de DNS/DNF que criamos anteriormente
    Operation::StatusCleanupService.process_absent_athletes(event)
    
    # Notifica o painel geral
    Turbo::StreamsChannel.broadcast_replace_to(
      "event_#{event.id}_broadcasts",
      target: "event_status_badge",
      html: "<span class='bg-gray-900 text-white px-3 py-1 rounded-full text-xs font-black animate-bounce'>PROVA ENCERRADA</span>"
    )
  end
end