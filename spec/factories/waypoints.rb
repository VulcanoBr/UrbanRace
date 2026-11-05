# frozen_string_literal: true

FactoryBot.define do
  factory :waypoint do
    association :route
    nome { "Km 5 - Posto de Hidratação" }
    km { 5.0 }
    eh_largada { false }
    eh_chegada { false }

    trait :largada do
      nome { "Largada" }
      km { 0.0 }
      eh_largada { true }
    end

    trait :chegada do
      nome { "Chegada" }
      km { 10.0 }
      eh_chegada { true }
    end

    trait :fechado do
      closed_at { Time.current }
      association :closed_by, factory: :organizer
    end
  end
end
