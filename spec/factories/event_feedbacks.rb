# frozen_string_literal: true

FactoryBot.define do
  factory :event_feedback do
    association :calendar
    association :admin
    comments { 'Great event!' }
    submitted_at { Time.current }
  end
end

