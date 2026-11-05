# frozen_string_literal: true

FactoryBot.define do
  factory :certificate do
    association :result
    association :athlete
    sequence(:qr_code_hash) { |n| "qr_#{n}_#{SecureRandom.hex(8)}" }
    gerado_em { Time.current }
  end
end
