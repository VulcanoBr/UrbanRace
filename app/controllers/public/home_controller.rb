
class Public::HomeController < ApplicationController
  allow_unauthenticated_access # only: :index 

  def index
    upcoming_cache_key = "upcoming_events_v1/#{Event.published.maximum(:updated_at).to_i}"

    @upcoming_events = Rails.cache.fetch(upcoming_cache_key, expires_in: 1.hour) do
      Event.published
           .where("data_largada >= ?", Date.today)
           .order(data_largada: :asc)
           .with_attached_banner
           .includes(distances: :lots)
           .to_a
    end

    past_cache_key = "past_events_v1/#{Event.maximum(:updated_at).to_i}"
    
    @past_events = Rails.cache.fetch(past_cache_key, expires_in: 1.hour) do
      Event.where(status: :finished)
           .or(Event.where("data_largada < ?", Date.today))
           .order(data_largada: :desc)
           .limit(6)
           .includes(:distances)
           .to_a
    end
  end
end