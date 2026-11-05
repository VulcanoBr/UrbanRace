# app/controllers/public/events_controller.rb
class Public::EventsController < ApplicationController
  allow_unauthenticated_access

  before_action :set_event

  def show
    @distances =
      @event
        .distances
        .includes(
          :categories,
          :lots
        )

    @current_lots =
      Lot
        .atuais
        .joins(:distance)
        .where(
          distances: {
            event_id: @event.id
          }
        )

    @related_events =
      Event
        .published
        .where.not(id: @event.id)
        .limit(3)
  end

  private

  def set_event
    @event = Event.published
                  .includes(:distances, :routes, sponsor_contracts: { sponsor: { logo_attachment: :blob } })
                  .find_by!(slug_url: params[:slug])
  end
end