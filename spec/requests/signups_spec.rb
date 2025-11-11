# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Signups', type: :request do
  let(:admin) { create(:admin) }
  let(:calendar) { create(:calendar, event_date: 1.day.from_now) }

  before do
    sign_in admin, scope: :admin
  end

  describe 'POST /calendars/:calendar_id/signup' do
    it 'creates a signup' do
      expect do
        post signup_calendar_path(calendar)
      end.to change(Signup, :count).by(1)
      expect(response).to redirect_to(home_path)
    end

    it 'shows success message' do
      post signup_calendar_path(calendar)
      expect(flash[:success]).to include('Successfully signed up')
    end

    it 'handles duplicate signup' do
      create(:signup, admin: admin, calendar: calendar)
      post signup_calendar_path(calendar)
      expect(flash[:alert]).to be_present
    end

    it 'prevents signing up for past events' do
      past_calendar = build(:calendar, event_date: 1.hour.ago)
      past_calendar.save(validate: false)
      post signup_calendar_path(past_calendar)
      expect(flash[:alert]).to be_present
    end
  end

  describe 'DELETE /calendars/:calendar_id/signup' do
    it 'destroys a signup' do
      create(:signup, admin: admin, calendar: calendar)
      expect do
        delete signout_calendar_path(calendar)
      end.to change(Signup, :count).by(-1)
      expect(response).to redirect_to(home_path)
    end

    it 'shows success message' do
      create(:signup, admin: admin, calendar: calendar)
      delete signout_calendar_path(calendar)
      expect(flash[:success]).to include('Successfully signed out')
    end

    it 'handles non-existent signup' do
      delete signout_calendar_path(calendar)
      expect(flash[:alert]).to include('not signed up')
    end
  end
end

