# frozen_string_literal: true

FactoryBot.define do
  factory :signup do
    association :calendar
    association :admin
  end
end

