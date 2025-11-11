# frozen_string_literal: true

FactoryBot.define do
  factory :event_signup do
    user_email { 'MyString' }
    user_name { 'MyString' }
    calendar { nil }
    signed_up_at { '2025-10-20 21:16:53' }
  end
end
