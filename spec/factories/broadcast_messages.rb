# frozen_string_literal: true

FactoryBot.define do
  factory :broadcast_message do
    association :event
    association :sender, factory: :organizer
    titulo { "Alerta de Largada" }
    corpo { "Falta 15 minutos para a largada da prova de 10km" }
    categoria { "info" }
    sent_at { Time.current }

    trait :informativo do
      categoria { "info" }
    end

    trait :urgente do
      categoria { "critical" }
      titulo { "EMERGÊNCIA NA PISTA" }
    end
  end
end
