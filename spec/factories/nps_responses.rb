# frozen_string_literal: true

FactoryBot.define do
  factory :nps_response do
    association :athlete
    association :event
    association :result
    nota_geral { 10 }
    nota_percurso { 9 }
    nota_organizacao { 10 }
    nota_estrutura { 9 }
    nota_comunicacao { 10 }
    comentario { "Evento sensacional! Percurso bem marcado." }
    respondido_em { Time.current }

    trait :promotor do
      nota_geral { 10 }
    end

    trait :detrator do
      nota_geral { 4 }
      comentario { "Faltou água no km 7" }
    end
  end
end
