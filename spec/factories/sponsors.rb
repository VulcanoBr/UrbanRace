# frozen_string_literal: true

FactoryBot.define do
  factory :sponsor do
    nome { Faker::Company.name }
    sequence(:cnpj) { |n| sprintf("%014d", 20000000000000 + n) }
    contato { Faker::Name.name }
    sequence(:email_contato) { |n| "patrocinador#{n}@example.com" }
    phone_contato { "21966666666" }
    website { "www.patrocinador.com.br" }
    ativo { true }

    trait :ativo do
      ativo { true }
    end

    trait :inativo do
      ativo { false }
    end
  end
end
