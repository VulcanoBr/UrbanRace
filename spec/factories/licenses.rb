FactoryBot.define do
  factory :license do
    association :event

    tipo              { "Alvará da Prefeitura" }
    orgao             { "Prefeitura Municipal" }
    prazo_solicitacao { 30.days.from_now.to_date }
    prazo_aprovacao   { 15.days.from_now.to_date }
    status            { "pending" }

    trait :expiring_soon do
      status          { "pending" }
      prazo_aprovacao { 7.days.from_now.to_date }
    end

    trait :approved do
      status          { "approved" }
      prazo_aprovacao { 30.days.from_now.to_date }
    end

    trait :expired do
      status          { "expired" }
      prazo_aprovacao { 5.days.ago.to_date }
    end

    trait :pendente do
      status { "pending" }
    end

    trait :aprovado do
      status { "approved" }
    end

    trait :vencido do
      status { "expired" }
    end
  end
end
