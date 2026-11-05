# frozen_string_literal: true

FactoryBot.define do
  factory :volunteer_station do
    association :event
    association :distance
    nome { "Posto de Hidratação KM 5" }
    tipo { "Hidratação" }
    km_posicao { 5.0 }
    vagas { 10 }
  end
end
