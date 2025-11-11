# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Calendar, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      calendar = build(:calendar)
      expect(calendar).to be_valid
    end

    it 'requires title' do
      calendar = build(:calendar, title: nil)
      expect(calendar).not_to be_valid
      expect(calendar.errors[:title]).to be_present
    end

    it 'requires event_date' do
      calendar = build(:calendar, event_date: nil)
      expect(calendar).not_to be_valid
      expect(calendar.errors[:event_date]).to be_present
    end

    it 'requires description' do
      calendar = build(:calendar, description: nil)
      expect(calendar).not_to be_valid
      expect(calendar.errors[:description]).to be_present
    end

    it 'requires category' do
      calendar = build(:calendar, category: nil)
      expect(calendar).not_to be_valid
      expect(calendar.errors[:category]).to be_present
    end

    it 'validates category inclusion' do
      calendar = build(:calendar, category: 'Invalid')
      expect(calendar).not_to be_valid
      expect(calendar.errors[:category]).to be_present
    end

    it 'accepts valid categories' do
      %w[Service Bush\ School Social].each do |category|
        calendar = build(:calendar, category: category)
        expect(calendar).to be_valid
      end
    end
  end

  describe 'event_date validation' do
    it 'allows events from yesterday onwards' do
      calendar = build(:calendar, event_date: 1.day.ago)
      expect(calendar).to be_valid
    end

    it 'allows events in the future' do
      calendar = build(:calendar, event_date: 1.day.from_now)
      expect(calendar).to be_valid
    end

    it 'rejects events more than 1 day in the past' do
      calendar = build(:calendar, event_date: 2.days.ago)
      expect(calendar).not_to be_valid
      expect(calendar.errors[:event_date]).to be_present
    end
  end

  describe 'associations' do
    it 'has many signups' do
      calendar = create(:calendar)
      admin = create(:admin)
      signup = create(:signup, calendar: calendar, admin: admin)
      expect(calendar.signups).to include(signup)
    end

    it 'has many signed_up_users through signups' do
      calendar = create(:calendar)
      admin = create(:admin)
      create(:signup, calendar: calendar, admin: admin)
      expect(calendar.signed_up_users).to include(admin)
    end

    it 'has many event_feedbacks' do
      calendar = create(:calendar)
      admin = create(:admin)
      feedback = create(:event_feedback, calendar: calendar, admin: admin)
      expect(calendar.event_feedbacks).to include(feedback)
    end
  end

  describe '#signup_count' do
    it 'returns the number of signups' do
      calendar = create(:calendar)
      create_list(:signup, 3, calendar: calendar)
      expect(calendar.signup_count).to eq(3)
    end
  end

  describe '#user_signed_up?' do
    it 'returns true if user with email has signed up' do
      calendar = create(:calendar)
      admin = create(:admin, email: 'test@example.com')
      create(:signup, calendar: calendar, admin: admin)
      expect(calendar.user_signed_up?('test@example.com')).to be true
    end

    it 'returns false if user with email has not signed up' do
      calendar = create(:calendar)
      expect(calendar.user_signed_up?('test@example.com')).to be false
    end
  end
end

