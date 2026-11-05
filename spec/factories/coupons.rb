# frozen_string_literal: true

FactoryBot.define do
  factory :coupon do
    association :event
    sequence(:codigo) { |n| "CUPOM#{n}" }
    tipo { "percentual" }
    valor { 10.0 }
    uso_maximo { 100 }
    uso_atual { 0 }
    validade { 30.days.from_now }

    trait :percentual do
      tipo { "percentual" }
      valor { 15.0 }
    end

    trait :fixo do
      tipo { "fixo" }
      valor { 20.0 }
    end

    trait :expirado do
      validade { 1.day.ago }
    end

    trait :esgotado do
      uso_maximo { 5 }
      uso_atual { 5 }
    end
  end
end
