# app/controllers/organizer/cbat_exports_controller.rb
class Organizer::CbatExportsController < Organizer::BaseController
  def show
    @event = Event.find(params[:event_id])
    service = Organizer::CbatExportService.new(@event)
    
    send_data service.generate_csv, 
              filename: "exportacao_cbat_#{@event.nome.parameterize}_#{Date.today}.csv",
              type: "text/csv"
  end
end