# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Signup, type: :model do
  describe 'validations' do
    it 'is valid with default factory data' do
      expect(build(:signup)).to be_valid
    end

    it 'enforces uniqueness for the same admin and calendar combination' do
      calendar = create(:calendar)
      admin = create(:admin)
      create(:signup, calendar: calendar, admin: admin)

      duplicate = build(:signup, calendar: calendar, admin: admin)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:admin_id]).to include('has already signed up for this event')
    end

    it 'rejects signups when the event is in the past' do
      travel_to Time.zone.local(2025, 1, 1, 10, 0, 0) do
        calendar = create(:calendar, event_date: 1.hour.ago)
        signup = build(:signup, calendar: calendar)

        expect(signup).not_to be_valid
        expect(signup.errors[:calendar]).to include('cannot sign up for events that have already occurred')
      end
    end
  end
end

