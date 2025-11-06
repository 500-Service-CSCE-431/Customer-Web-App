# frozen_string_literal: true

FactoryBot.define do
  factory :calendar do
    title { 'Team Meeting' }
    event_date { DateTime.new(2024, 12, 25, 14, 0, 0) }
    description { 'Weekly team standup meeting to discuss project progress' }
    location { 'Conference Room A' }
  end
end
