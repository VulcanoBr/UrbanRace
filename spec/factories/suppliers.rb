# frozen_string_literal: true

FactoryBot.define do
  factory :supplier do
    razao_social { Faker::Company.name }
    sequence(:cnpj) { |n| sprintf("%014d", 10000000000000 + n) }
    contato { Faker::Name.name }
    sequence(:email_contato) { |n| "fornecedor#{n}@example.com" }
    phone_contato { "21977777777" }
    tipo_servico { "Cronometragem Eletrônica" }
    avaliacao_media { 4.8 }
  end
end
