# frozen_string_literal: true

FactoryBot.define do
  factory :athlete_checkin do
    association :registration
    association :volunteer_station
    realizado_em { Time.current }
    offline { false }
    sincronizado { true }

    trait :online do
      offline { false }
      sincronizado { true }
    end

    trait :offline do
      offline { true }
      sincronizado { false }
    end
  end
end
