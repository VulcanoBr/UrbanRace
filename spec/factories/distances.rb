# frozen_string_literal: true

FactoryBot.define do
  factory :distance do
    association :event

    sequence(:nome) { |n| "#{5 + n}K" }

    km { 5.0 }
    vagas_total { 500 }
    vagas_ocupadas { 0 }

    trait :cinco_km do
      nome { "5K" }
      km { 5.0 }
    end

    trait :dez_km do
      nome { "10K" }
      km { 10.0 }
    end

    trait :meia_maratonista do
      nome { "21K" }
      km { 21.1 }
    end
  end
end