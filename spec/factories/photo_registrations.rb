# frozen_string_literal: true

FactoryBot.define do
  factory :photo_registration do
    association :photo
    association :registration
    confianca_ocr { 90 }
    confirmado_manualmente { false }

    trait :alta_confianca do
      confianca_ocr { 95 }
    end

    trait :confirmado do
      confirmado_manualmente { true }
    end
  end
end
