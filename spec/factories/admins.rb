# frozen_string_literal: true

FactoryBot.define do
  factory :admin do
    email { Faker::Internet.email }
    full_name { Faker::Name.name }
    role { 'member' }
    uid { SecureRandom.hex(10) }
    encrypted_password { Devise.friendly_token[0, 20] }

    trait :admin_role do
      role { 'admin' }
    end
  end
end
