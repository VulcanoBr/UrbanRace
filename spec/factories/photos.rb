# frozen_string_literal: true

FactoryBot.define do
  factory :photo do
    association :event
    url_arquivo { "https://s3.amazonaws.com/urbanrace/photos/1.jpg" }
    tipo { "atleta" }
    reconhecido_ia { false }
    enviada_em { Time.current }

    trait :atleta do
      tipo { "atleta" }
    end

    trait :evento do
      tipo { "evento" }
    end

    trait :identificada do
      reconhecido_ia { true }
      confianca_ocr { 95 }
    end
  end
end
