# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventFeedback, type: :model do
  it 'is valid with default factory data' do
    expect(build(:event_feedback)).to be_valid
  end

  it 'requires comments' do
    feedback = build(:event_feedback, comments: '')
    expect(feedback).not_to be_valid
    expect(feedback.errors[:comments]).to include("can't be blank")
  end

  it 'requires submitted_at' do
    feedback = build(:event_feedback, submitted_at: nil)
    expect(feedback).not_to be_valid
    expect(feedback.errors[:submitted_at]).to include("can't be blank")
  end

  it 'enforces one feedback per admin per event' do
    calendar = create(:calendar)
    admin = create(:admin)
    create(:event_feedback, calendar: calendar, admin: admin)

    duplicate = build(:event_feedback, calendar: calendar, admin: admin)
    expect(duplicate).not_to be_valid
    expect(duplicate.errors[:admin_id]).to include('has already submitted feedback for this event')
  end
end
