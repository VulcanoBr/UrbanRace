# frozen_string_literal: true

FactoryBot.define do
  factory :timing do
    association :registration
    association :waypoint
    gun_time { "00:45:10" }
    chip_time { "00:44:30" }
    posicao_geral { 1 }
    posicao_categoria { 1 }
    pace_km { "04:27" }
  end
end
