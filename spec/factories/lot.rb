FactoryBot.define do
  factory :lot do
    association :distance

    numero { 1 }
    preco { 150.00 }
    vagas { 500 }
    abertura { 1.day.ago }
    encerramento { 30.days.from_now }
    status { "active" }

    trait :vigente do
      abertura { 1.day.ago }
      encerramento { 30.days.from_now }
      status { "active" }
    end

    trait :futuro do
      abertura { 2.days.from_now }
      encerramento { 30.days.from_now }
      status { "active" }
    end

    trait :passado do
      abertura { 30.days.ago }
      encerramento { 1.day.ago }
      status { "active" }
    end
  end
end