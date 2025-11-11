# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    sequence(:email) { |n| "user#{n}@example.com" }
    full_name { 'Test Admin' }
    role { 'member' }
    uid { SecureRandom.uuid }
    encrypted_password { 'oauth_user' }

    trait :admin_role do
      role { 'admin' }
    end
  end
end
