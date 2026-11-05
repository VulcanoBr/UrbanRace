# frozen_string_literal: true

FactoryBot.define do
  factory :waitlist do
    association :athlete
    association :category
    association :distance
    association :event
    association :lot
    sequence(:posicao) { |n| n }
    data_entrada { Time.current }
    status { "aguardando" }

    trait :aguardando do
      status { "aguardando" }
    end

    trait :notificado do
      status { "notificado" }
    end

    trait :expirado do
      status { "expirado" }
    end
  end
end
