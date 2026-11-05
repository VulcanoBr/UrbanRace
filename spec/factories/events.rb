# spec/factories/event.rb
# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    association :organizer

    sequence(:nome) { |n| "Corrida #{n}" }
    sequence(:slug_url) { |n| "corrida-#{n}" }

    data_largada { 3.months.from_now.to_date }
    horario_largada { Time.zone.parse("07:00") }
    cidade { "Rio de Janeiro" }
    estado { "RJ" }
    local_partida { "Aterro do Flamengo" }
    limite_atletas { 1000 }
    status { "draft" }

    trait :published do
      status { "published" } # ou o valor/enum correspondente
    end
  end
end