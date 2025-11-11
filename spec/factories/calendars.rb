# frozen_string_literal: true

FactoryBot.define do
  factory :calendar do
    sequence(:title) { |n| "Team Meeting #{n}" }
    event_date { 3.days.from_now }
    description { 'Weekly team standup meeting to discuss project progress' }
    location { 'Conference Room A' }
    category { 'Service' }
  end
end
