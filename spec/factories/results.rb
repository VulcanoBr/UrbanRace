# spec/factories/result.rb
FactoryBot.define do
  factory :result do
    association :registration

    posicao_geral         { 1 }
    posicao_categoria     { 1 }
    posicao_sexo          { 1 }
    posicao_faixa_etaria  { 1 }

    tempo_bruto   { "00:45:00" }
    tempo_liquido { "00:44:30" }

    status_finalizacao { "concluido" }
    homologado { false }

    trait :concluido do
      status_finalizacao { "concluido" }
      tempo_liquido { "00:44:30" }
    end

    trait :homologado do
      homologado    { true }
      homologado_em { Time.current }
    end

    trait :dns do
      status_finalizacao { "dns" }
      tempo_liquido      { nil }
      tempo_bruto        { nil }
    end

    trait :dnf do
      status_finalizacao { "dnf" }
      tempo_liquido      { nil }
    end
  end
end