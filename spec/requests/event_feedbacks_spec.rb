# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'EventFeedbacks', type: :request do
  describe 'POST /calendars/:calendar_id/event_feedbacks' do
    let(:member) { create(:admin) }
    let(:calendar) { create(:calendar, event_date: 1.hour.from_now) }

    before do
      sign_in member
      create(:signup, calendar: calendar, admin: member)
    end

    it 'creates a feedback entry for an eligible attendee' do
      travel_to 2.hours.from_now do
        expect do
          post calendar_event_feedbacks_path(calendar),
               params: { event_feedback: { comments: 'Awesome event!' } }
        end.to change(EventFeedback, :count).by(1)

        expect(response).to redirect_to(show_calendar_path(calendar))
        follow_redirect!
        expect(response.body).to include('Thanks for sharing your feedback!')
      end
    end

    it 'updates an existing feedback entry' do
      travel_to 2.hours.from_now do
        post calendar_event_feedbacks_path(calendar),
             params: { event_feedback: { comments: 'Great' } }

        expect do
          post calendar_event_feedbacks_path(calendar),
               params: { event_feedback: { comments: 'Even better' } }
        end.not_to change(EventFeedback, :count)

        expect(EventFeedback.last.comments).to eq('Even better')
      end
    end

    it 'rejects users who did not attend the event' do
      other_calendar = create(:calendar, event_date: 1.hour.from_now)

      travel_to 2.hours.from_now do
        expect do
          post calendar_event_feedbacks_path(other_calendar),
               params: { event_feedback: { comments: 'Should fail' } }
        end.not_to change(EventFeedback, :count)

        expect(response).to redirect_to(show_calendar_path(other_calendar))
        follow_redirect!
        expect(response.body).to include('You can only leave feedback for events you attended')
      end
    end
  end

  describe 'GET /admin/feedbacks' do
    it 'allows admins to view feedback for a specific month' do
      admin = create(:admin, :admin_role)
      sign_in admin

      travel_to Time.zone.local(2025, 1, 15, 10, 0, 0) do
        calendar = create(:calendar, event_date: Time.zone.local(2025, 1, 10, 12, 0, 0))
        feedback = create(:event_feedback, calendar: calendar, admin: admin, comments: 'Insightful!', submitted_at: Time.current)

        get admin_feedbacks_path, params: { month: 1, year: 2025 }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include(calendar.title)
        expect(response.body).to include(feedback.comments)
      end
    end

    it 'redirects non-admin users away from the feedback dashboard' do
      member = create(:admin)
      sign_in member

      get admin_feedbacks_path

      expect(response).to redirect_to(home_path)
    end
  end
end

