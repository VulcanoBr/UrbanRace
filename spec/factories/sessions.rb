# frozen_string_literal: true

FactoryBot.define do
  factory :session do
    association :user, factory: :athlete
    ip_address { "127.0.0.1" }
    user_agent { "Mozilla/5.0" }
    expires_at { 1.day.from_now }

    trait :organizer_session do
      association :user, factory: :organizer
    end
  end
end
