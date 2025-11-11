# frozen_string_literal: true

FactoryBot.define do
  factory :calendar do
    title { 'Team Meeting' }
    event_date { 1.day.from_now }
    description { 'Weekly team standup meeting to discuss project progress' }
    location { 'Conference Room A' }
    category { 'Service' }
  end
end
