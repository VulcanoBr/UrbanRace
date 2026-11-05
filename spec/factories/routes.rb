# frozen_string_literal: true

FactoryBot.define do
  factory :route do
    association :event
    distance { association :distance, event: event }
    geojson_traca do
      {
        "type" => "Feature",
        "geometry" => {
          "type" => "LineString",
          "coordinates" => [[-43.1729, -22.9068], [-43.1750, -22.9090]]
        }
      }
    end
    pontos_apoio { [] }
  end
end
