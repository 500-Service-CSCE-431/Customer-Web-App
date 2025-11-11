# frozen_string_literal: true

FactoryBot.define do
  factory :signup do
    association :admin
    association :calendar
  end
end

