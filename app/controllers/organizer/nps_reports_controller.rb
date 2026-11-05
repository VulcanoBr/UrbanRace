class Organizer::NpsReportsController < Organizer::BaseController
  before_action :set_event

  def show
    @analytics = Organizer::NpsAnalyticsService.new(@event)
    @report = @analytics.calculate_report
  end

  private

  def set_event
    # Busca pelo slug_url conforme os parâmetros enviados
    @event = Current.user.events.find_by!(slug_url: params[:event_id])
  end
end