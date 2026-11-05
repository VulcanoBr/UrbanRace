# frozen_string_literal: true

FactoryBot.define do
  factory :payment do
    association :registration
    metodo { "pix" }
    status { "pendente" }
    valor { 100.00 }
    gateway_provider { "stripe" }
    sequence(:gateway_id) { |n| "gtw_#{n}_#{SecureRandom.hex(6)}" }

    trait :pendente do
      status { "pendente" }
    end

    trait :pago do
      status { "pago" }
      pago_em { Time.current }
    end

    trait :estornado do
      status { "estornado" }
      pago_em { 1.day.ago }
    end

    trait :cancelado do
      status { "cancelado" }
    end

    trait :pix do
      metodo { "pix" }
    end

    trait :cartao do
      metodo { "cartao" }
    end

    trait :boleto do
      metodo { "boleto" }
      vencimento { 3.days.from_now }
    end
  end
end
