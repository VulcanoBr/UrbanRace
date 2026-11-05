# frozen_string_literal: true

FactoryBot.define do
  factory :sponsor_contract do
    association :sponsor
    association :event
    cota { "Master" }
    valor_cota { "15000.00" }
    status { "negotiating" }

    trait :negociacao do
      status { "negotiating" }
    end

    trait :assinado do
      status { "signed" }
      assinado_em { Time.current.to_date }
    end
  end
end
