module Athletes

  class ResultsController < BaseController

    def index
      service = ResultsService.new(Current.user)

      @data = service.call
    end

    def show
      @result = Result.joins(:registration)
                      .where(registrations: { athlete_id: current_user.id })
                      .includes(:certificate, registration: [:event, :distance, :category])
                      .find(params[:id])

      # Agora @result está preenchido corretamente para a view
      @performance = Athletes::PerformanceService.new(@result).data
    rescue ActiveRecord::RecordNotFound
      redirect_to athletes_results_path, alert: "Resultado não encontrado ou acesso negado."
    end

  end

end