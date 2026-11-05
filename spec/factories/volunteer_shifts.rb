# frozen_string_literal: true

FactoryBot.define do
  factory :volunteer_shift do
    association :volunteer_station
    association :volunteer
    turno { "manha" }
    status { "pendente" }

    trait :confirmado do
      status { "confirmado" }
      checkin_em { Time.current }
    end

    trait :cancelado do
      status { "cancelado" }
    end
  end
end
