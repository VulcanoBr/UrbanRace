FactoryBot.define do
  factory :category do
    association :distance

    nome { "Masculino 18-39" }

    sexo { "masculino" }

    idade_min { 18 }

    idade_max { 39 }

    trait :masculino do
      nome { "Masculino 18-39" }
      sexo { "masculino" }
    end

    trait :feminino do
      nome { "Feminino 18-39" }
      sexo { "feminino" }
    end

    trait :unissex do
      nome { "Unissex 18-39" }
      sexo { "unissex" }
    end
  end
end