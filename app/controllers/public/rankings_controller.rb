module Public
  class RankingsController < ApplicationController
    allow_unauthenticated_access only: :show

    def show
      @event = Event
           .includes(distances: [:categories])
           .find_by!(slug_url: params[:slug])

      @service = EventRankingService.new(@event)

      @distance =
          if params[:distance_id].present?
            @event.distances.find_by(id: params[:distance_id])
          end

      @distance ||= @event.distances.order(:km).first

      @category =
        if params[:category_id].present?
          @distance.categories.find_by(id: params[:category_id])
        end

      @category ||= @distance.categories.order(:nome).first

      @ranking =
        @service.ranking(
          distance: @distance,
          category: @category
        )
    end
  end
end