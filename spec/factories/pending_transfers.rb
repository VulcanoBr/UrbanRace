# frozen_string_literal: true

FactoryBot.define do
  factory :pending_transfer do
    association :transfer
    association :registration
    sequence(:email_destino) { |n| "pending_destino#{n}@example.com" }
    sequence(:cpf_destino) { |n| CPF.generate }
    status { "aguardando" }
    expira_em { 48.hours.from_now }

    trait :aguardando do
      status { "aguardando" }
    end

    trait :expirado do
      status { "expirado" }
      expira_em { 1.hour.ago }
    end
  end
end
