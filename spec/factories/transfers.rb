# frozen_string_literal: true

FactoryBot.define do
  factory :transfer do
    association :registration
    association :athlete_origem, factory: :athlete
    association :athlete_destino, factory: :athlete
    status { "pendente" }
    taxa { 0 }
    solicitada_em { Time.current }
    sequence(:email_destino) { |n| "destino#{n}@example.com" }
    sequence(:token) { |n| "token_#{n}_#{SecureRandom.hex(16)}" }
    token_expira_em { 48.hours.from_now }

    trait :pendente do
      status { "pendente" }
    end

    trait :concluida do
      status { "concluido" }
      concluida_em { Time.current }
    end

    trait :expirada do
      status { "expirado" }
      token_expira_em { 1.hour.ago }
    end
  end
end
