# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Calendar, type: :model do
  describe 'validations' do
    it 'is valid with the default factory' do
      expect(build(:calendar)).to be_valid
    end

    it 'requires a title' do
      calendar = build(:calendar, title: nil)
      expect(calendar).not_to be_valid
      expect(calendar.errors[:title]).to be_present
    end

    it 'requires an event date' do
      calendar = build(:calendar, event_date: nil)
      expect(calendar).not_to be_valid
      expect(calendar.errors[:event_date]).to be_present
    end

    it 'requires a description' do
      calendar = build(:calendar, description: nil)
      expect(calendar).not_to be_valid
      expect(calendar.errors[:description]).to be_present
    end

    it 'requires a valid category' do
      calendar = build(:calendar, category: 'Unknown')
      expect(calendar).not_to be_valid
      expect(calendar.errors[:category]).to include('is not included in the list')
    end

    it 'does not allow dates in the past' do
      calendar = build(:calendar, event_date: 1.day.ago)
      expect(calendar).not_to be_valid
      expect(calendar.errors[:event_date]).to include('must be in the future')
    end

    it 'allows dates later on the same day' do
      travel_to Time.zone.local(2025, 1, 1, 10, 0, 0) do
        calendar = build(:calendar, event_date: Time.zone.local(2025, 1, 1, 11, 0, 0))
        expect(calendar).to be_valid
      end
    end
  end

  describe '#signup_count' do
    it 'returns the number of signups for the event' do
      calendar = create(:calendar)
      create_list(:signup, 2, calendar: calendar)

      expect(calendar.signup_count).to eq(2)
    end
  end

  describe '#user_signed_up?' do
    it 'returns true when the specific user is signed up' do
      calendar = create(:calendar)
      admin = create(:admin)
      create(:signup, calendar: calendar, admin: admin)

      expect(calendar.user_signed_up?(admin.email)).to be true
    end

    it 'returns false when the user is not signed up' do
      calendar = create(:calendar)

      expect(calendar.user_signed_up?('absent@example.com')).to be false
    end
  end
end
