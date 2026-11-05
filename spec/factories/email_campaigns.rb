# frozen_string_literal: true

FactoryBot.define do
  factory :email_campaign do
    association :event
    assunto { "Informações importantes para a largada" }
    segmento { "todos_inscritos" }
    enviados { 0 }
    abertos { 0 }
    clicados { 0 }
  end
end
