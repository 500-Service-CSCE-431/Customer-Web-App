# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventSignup, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      event_signup = build(:event_signup)
      expect(event_signup).to be_valid
    end

    it 'requires user_email' do
      event_signup = build(:event_signup, user_email: nil)
      expect(event_signup).not_to be_valid
      expect(event_signup.errors[:user_email]).to be_present
    end

    it 'requires user_name' do
      event_signup = build(:event_signup, user_name: nil)
      expect(event_signup).not_to be_valid
      expect(event_signup.errors[:user_name]).to be_present
    end

    it 'validates email format' do
      event_signup = build(:event_signup, user_email: 'invalid_email')
      expect(event_signup).not_to be_valid
      expect(event_signup.errors[:user_email]).to be_present
    end

    it 'accepts valid email format' do
      event_signup = build(:event_signup, user_email: 'test@example.com')
      expect(event_signup).to be_valid
    end

    it 'validates uniqueness of user_email scoped to calendar_id' do
      calendar = create(:calendar)
      create(:event_signup, calendar: calendar, user_email: 'test@example.com')
      duplicate = build(:event_signup, calendar: calendar, user_email: 'test@example.com')
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_email]).to be_present
    end

    it 'allows same email for different calendars' do
      calendar1 = create(:calendar)
      calendar2 = create(:calendar)
      create(:event_signup, calendar: calendar1, user_email: 'test@example.com')
      duplicate = build(:event_signup, calendar: calendar2, user_email: 'test@example.com')
      expect(duplicate).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to calendar' do
      calendar = create(:calendar)
      event_signup = create(:event_signup, calendar: calendar)
      expect(event_signup.calendar).to eq(calendar)
    end
  end

  describe 'scopes' do
    it 'filters by user email' do
      create(:event_signup, user_email: 'test@example.com')
      create(:event_signup, user_email: 'other@example.com')
      expect(EventSignup.for_user('test@example.com').count).to eq(1)
    end

    it 'filters upcoming events' do
      past_calendar = create(:calendar, event_date: 1.day.ago)
      future_calendar = create(:calendar, event_date: 1.day.from_now)
      create(:event_signup, calendar: past_calendar)
      create(:event_signup, calendar: future_calendar)
      expect(EventSignup.upcoming.count).to eq(1)
    end
  end
end

