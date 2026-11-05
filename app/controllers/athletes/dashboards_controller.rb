class Athletes::DashboardsController < Athletes::BaseController
  def show
    service = Athletes::PortalService.new(Current.user)
    @data = service.dashboard_data
  end
end