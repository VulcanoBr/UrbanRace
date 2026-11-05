# frozen_string_literal: true

FactoryBot.define do
  factory :supplier_contract do
    
    association :supplier
    association :event
    valor { 5000.00 }
    status { "negociacao" }

    trait :negociacao do
      status { "negociacao" }
    end

    trait :assinado do
      status { "assinado" }
      assinado_em { Time.current.to_date }
    end
  end
end
