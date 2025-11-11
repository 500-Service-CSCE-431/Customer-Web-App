# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventFeedback, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      feedback = build(:event_feedback)
      expect(feedback).to be_valid
    end

    it 'requires comments' do
      feedback = build(:event_feedback, comments: nil)
      expect(feedback).not_to be_valid
      expect(feedback.errors[:comments]).to be_present
    end

    it 'validates comments length is within maximum' do
      feedback = build(:event_feedback, comments: 'a' * 2001)
      expect(feedback).not_to be_valid
      expect(feedback.errors[:comments]).to be_present
    end

    it 'accepts comments within maximum length' do
      feedback = build(:event_feedback, comments: 'a' * 2000)
      expect(feedback).to be_valid
    end

    it 'requires submitted_at' do
      feedback = build(:event_feedback, submitted_at: nil)
      expect(feedback).not_to be_valid
      expect(feedback.errors[:submitted_at]).to be_present
    end
  end

  describe 'associations' do
    it 'belongs to calendar' do
      calendar = create(:calendar)
      feedback = create(:event_feedback, calendar: calendar)
      expect(feedback.calendar).to eq(calendar)
    end

    it 'belongs to admin' do
      admin = create(:admin)
      feedback = create(:event_feedback, admin: admin)
      expect(feedback.admin).to eq(admin)
    end
  end

  describe 'uniqueness constraint' do
    it 'validates uniqueness of admin_id scoped to calendar_id' do
      calendar = create(:calendar)
      admin = create(:admin)
      create(:event_feedback, calendar: calendar, admin: admin)
      duplicate = build(:event_feedback, calendar: calendar, admin: admin)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:admin_id]).to be_present
    end

    it 'allows same admin to provide feedback for different events' do
      calendar1 = create(:calendar)
      calendar2 = create(:calendar)
      admin = create(:admin)
      create(:event_feedback, calendar: calendar1, admin: admin)
      duplicate = build(:event_feedback, calendar: calendar2, admin: admin)
      expect(duplicate).to be_valid
    end
  end

  describe 'scopes' do
    it 'orders by submitted_at descending' do
      calendar1 = create(:calendar)
      calendar2 = create(:calendar)
      calendar3 = create(:calendar)
      admin = create(:admin)
      feedback1 = create(:event_feedback, calendar: calendar1, admin: admin, submitted_at: 2.days.ago)
      create(:event_feedback, calendar: calendar2, admin: admin, submitted_at: 1.day.ago)
      feedback3 = create(:event_feedback, calendar: calendar3, admin: admin, submitted_at: Time.current)
      ordered = EventFeedback.ordered
      expect(ordered.first).to eq(feedback3)
      expect(ordered.last).to eq(feedback1)
    end
  end
end

