# app/controllers/public/trackings_controller.rb
class Public::TrackingsController < ApplicationController
  allow_unauthenticated_access

  def show
    @event = Event.find_by!(slug_url: params[:slug])
    if params[:dorsal].present?
      @registration = @event.registrations.find_by(numero_dorsal: params[:dorsal])
      @last_timing = @registration&.timings&.order(created_at: :desc)&.first
    end
  end
end