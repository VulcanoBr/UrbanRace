FactoryBot.define do
  factory :athlete do
    nome { Faker::Name.name }

    sequence(:email_address) do |n|
      "atleta#{n}@example.com"
    end

    sequence(:cpf) do |n|
      # Recomendo substituir posteriormente
      # por gerador de CPF válido.
      CPF.generate
    end

    nascimento { 30.years.ago.to_date }
    sexo { "masculino" }
    telefone { "21999999999" }

    password { "password123" }
    password_confirmation { "password123" }
  end
end