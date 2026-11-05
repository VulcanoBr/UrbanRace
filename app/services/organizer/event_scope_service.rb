# frozen_string_literal: true

class Organizer::EventScopeService
  def initialize(organizer)
    @organizer = organizer
  end

  def active_event
    @organizer.events
              .order(data_largada: :desc)
              .first
  end

  
  def find_by_slug(slug)
    return nil if slug.blank?

    # Não aceitar IDs numéricos como se fossem slugs.
    return nil if slug.to_s.match?(/\A\d+\z/)

    @organizer.events.find_by!(slug_url: slug)
  rescue ActiveRecord::RecordNotFound
    # Distingue um slug inexistente de um evento pertencente
    # a outro organizador.
    return nil if Event.exists?(slug_url: slug)

    raise
  end


  def all_events
    @organizer.events
              .order(data_largada: :desc)
  end
end