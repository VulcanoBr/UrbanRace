# frozen_string_literal: true

FactoryBot.define do
  factory :volunteer do
    nome { Faker::Name.name }
    sequence(:email) { |n| "voluntario#{n}@example.com" }
    telefone { "21988888888" }
    funcao_preferida { "Hidratação" }
  end
end
