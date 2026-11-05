FactoryBot.define do
  factory :organizer do
    name { Faker::Name.name }
    email_address { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    role { "admin" }
  end
end