# frozen_string_literal: true

FactoryBot.define do
  factory :registration do
    association :athlete
    association :event

    # distance deve pertencer ao mesmo event
    distance { association(:distance, event: event) }

    # category deve pertencer à mesma distance
    category { association(:category, distance: distance) }

    # lot deve pertencer à mesma distance
    lot { association(:lot, distance: distance) }

    status { "confirmed" }
    tamanho_kit { "M" }
    contato_emergencia { "Maria Silva" }
    fone_emergencia { "21999999999" }
    aceite_lgpd { true }

    sequence(:numero_dorsal) do |n|
      1000 + n
    end

    trait :confirmed do
      status { :confirmado }
    end

    trait :checked_in do
      status { :checado }
    end

    trait :pendente do
      status      { "pending" }
      numero_dorsal { nil }
    end

    trait :transferred do
      status { :transferido }
    end

    trait :cancelled do
      status { :cancelado }
    end
  end
end