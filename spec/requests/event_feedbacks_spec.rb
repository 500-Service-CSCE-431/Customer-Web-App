# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'EventFeedbacks', type: :request do
  let(:admin) { create(:admin) }
  let(:past_calendar) { build(:calendar, event_date: 1.day.ago) }
  let(:future_calendar) { create(:calendar, event_date: 1.day.from_now) }

  before do
    past_calendar.save(validate: false)
    sign_in admin, scope: :admin
    # Create signup by bypassing validation since event is in the past
    signup = Signup.new(admin: admin, calendar: past_calendar)
    signup.save(validate: false)
  end

  describe 'POST /calendars/:calendar_id/event_feedbacks' do
    it 'creates feedback for past event' do
      expect do
        post calendar_event_feedbacks_path(past_calendar), params: {
          event_feedback: {
            comments: 'Great event!'
          }
        }
      end.to change(EventFeedback, :count).by(1)
      expect(response).to redirect_to(show_calendar_path(past_calendar))
    end

    it 'shows success message' do
      post calendar_event_feedbacks_path(past_calendar), params: {
        event_feedback: {
          comments: 'Great event!'
        }
      }
      expect(flash[:notice]).to include('Thanks for sharing')
    end

    it 'prevents feedback for future events' do
      create(:signup, admin: admin, calendar: future_calendar)
      post calendar_event_feedbacks_path(future_calendar), params: {
        event_feedback: {
          comments: 'Great event!'
        }
      }
      expect(flash[:alert]).to include('after they have occurred')
    end

    it 'prevents feedback if user did not attend' do
      other_calendar = build(:calendar, event_date: 2.days.ago)
      other_calendar.save(validate: false)
      post calendar_event_feedbacks_path(other_calendar), params: {
        event_feedback: {
          comments: 'Great event!'
        }
      }
      expect(flash[:alert]).to include('after they have occurred')
    end

    it 'handles validation errors' do
      post calendar_event_feedbacks_path(past_calendar), params: {
        event_feedback: {
          comments: ''
        }
      }
      expect(flash[:alert]).to be_present
    end
  end

  describe 'GET /admin/feedbacks' do
    let(:admin_user) { create(:admin, :admin_role) }

    before do
      sign_in admin_user, scope: :admin
    end

    it 'returns http success' do
      get admin_feedbacks_path
      expect(response).to have_http_status(:success)
    end

    it 'filters by month and year' do
      get admin_feedbacks_path, params: { month: 11, year: 2024 }
      expect(response).to have_http_status(:success)
    end

    it 'handles invalid month/year' do
      get admin_feedbacks_path, params: { month: 13, year: 2024 }
      expect(response).to have_http_status(:success)
    end
  end
end

