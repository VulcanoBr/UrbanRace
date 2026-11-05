# frozen_string_literal: true

FactoryBot.define do
  factory :supplier_delivery do
    association :supplier_contract
    descricao { "Entrega dos pórticos de largada e chegada" }
    data_prevista { 1.day.from_now.to_date }
    status { "pending" }

    trait :pendente do
      status { "pending" }
    end

    trait :concluida do
      status { "completed" }
      data_real { Time.current.to_date }
    end

    trait :atrasada do
      status { "pending" }
      data_prevista { 2.days.ago.to_date }
    end
  end
end
