# frozen_string_literal: true

FactoryBot.define do
  factory :incident do
    association :event
    association :responsavel, factory: :organizer
    tipo { "queda" }
    gravidade { "baixa" }
    km_local { 5.5 }
    ocorrida_em { Time.current }
    descricao { "Atleta tropeçou na sarjeta" }
    status { "aberto" }

    trait :baixa do
      gravidade { "baixa" }
    end

    trait :critica do
      gravidade { "critica" }
      tipo { "cardiaco" }
    end
  end
end
