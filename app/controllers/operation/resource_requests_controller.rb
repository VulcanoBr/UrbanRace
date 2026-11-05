# app/controllers/operation/resource_requests_controller.rb
class Operation::ResourceRequestsController < Operation::BaseController
  def create
    @station = VolunteerStation.find(params[:volunteer_station_id])
    @item = params[:item]
    
    # Notifica o Command Center via Turbo Stream (Solid Cable)
    Turbo::StreamsChannel.broadcast_prepend_to(
      "command_center_event_#{@station.event_id}",
      target: "incidents_list",
      partial: "operation/dashboards/resource_alert",
      locals: { station: @station, item: @item }
    )
    
    head :ok
  end
end