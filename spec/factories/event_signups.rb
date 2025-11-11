# frozen_string_literal: true

FactoryBot.define do
  factory :event_signup do
    user_email { Faker::Internet.email }
    user_name { Faker::Name.name }
    association :calendar
    signed_up_at { Time.current }
  end
end
