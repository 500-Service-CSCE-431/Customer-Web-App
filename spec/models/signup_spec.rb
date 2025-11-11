# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Signup, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      admin = create(:admin)
      calendar = create(:calendar)
      signup = build(:signup, admin: admin, calendar: calendar)
      expect(signup).to be_valid
    end

    it 'validates uniqueness of admin_id scoped to calendar_id' do
      admin = create(:admin)
      calendar = create(:calendar)
      create(:signup, admin: admin, calendar: calendar)
      duplicate = build(:signup, admin: admin, calendar: calendar)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:admin_id]).to be_present
    end

    it 'allows same admin for different calendars' do
      admin = create(:admin)
      calendar1 = create(:calendar)
      calendar2 = create(:calendar)
      create(:signup, admin: admin, calendar: calendar1)
      duplicate = build(:signup, admin: admin, calendar: calendar2)
      expect(duplicate).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to admin' do
      admin = create(:admin)
      signup = create(:signup, admin: admin)
      expect(signup.admin).to eq(admin)
    end

    it 'belongs to calendar' do
      calendar = create(:calendar)
      signup = create(:signup, calendar: calendar)
      expect(signup.calendar).to eq(calendar)
    end
  end

  describe 'event_not_in_past validation' do
    it 'allows signup for future events' do
      admin = create(:admin)
      future_time = 1.day.from_now
      calendar = create(:calendar, event_date: future_time)
      signup = build(:signup, admin: admin, calendar: calendar)
      expect(signup).to be_valid
    end

    it 'rejects signup for events that have already occurred' do
      admin = create(:admin)
      # Create an event that's in the past but still within Calendar's validation window (yesterday)
      past_time = 1.hour.ago
      # Use save(validate: false) to bypass Calendar validation since we're testing Signup validation
      calendar = build(:calendar, event_date: past_time)
      calendar.save(validate: false)
      signup = build(:signup, admin: admin, calendar: calendar)
      expect(signup).not_to be_valid
      expect(signup.errors[:calendar]).to be_present
      expect(signup.errors[:calendar].first).to include('cannot sign up for events that have already occurred')
    end

    it 'allows signup for events happening in the future (even if same day)' do
      admin = create(:admin)
      future_time = 2.hours.from_now
      calendar = create(:calendar, event_date: future_time)
      signup = build(:signup, admin: admin, calendar: calendar)
      expect(signup).to be_valid
    end
  end
end

