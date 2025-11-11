# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CalendarsHelper, type: :helper do
  describe '#calendar_share_url' do
    it 'builds a fully qualified URL based on the request base URL' do
      calendar = create(:calendar)
      allow(helper).to receive(:request).and_return(double(base_url: 'https://example.com'))

      expect(helper.calendar_share_url(calendar)).to eq("https://example.com/calendars/#{calendar.id}")
    end
  end

  describe '#calendar_qr_code_data_uri' do
    it 'returns a png data URI for the calendar share link' do
      calendar = create(:calendar)
      allow(helper).to receive(:calendar_share_url).with(calendar).and_return('https://example.com/events/1')

      data_uri = helper.calendar_qr_code_data_uri(calendar)
      expect(data_uri).to start_with('data:image/png;base64,')
    end
  end

  describe '#can_leave_feedback?' do
    let(:member) { create(:admin) }
    let(:calendar) { create(:calendar, event_date: 1.hour.from_now) }

    it 'returns true when the current user is signed in, attended, and the event has passed' do
      create(:signup, calendar: calendar, admin: member)

      travel_to 2.hours.from_now do
        allow(helper).to receive(:user_signed_in?).and_return(true)
        allow(helper).to receive(:current_user).and_return(member)

        expect(helper.can_leave_feedback?(calendar)).to be true
      end
    end

    it 'returns false when the event has not occurred yet' do
      allow(helper).to receive(:user_signed_in?).and_return(true)
      allow(helper).to receive(:current_user).and_return(member)
      create(:signup, calendar: calendar, admin: member)

      expect(helper.can_leave_feedback?(calendar)).to be false
    end
  end

  describe '#feedback_button_label' do
    it 'returns "Leave Feedback" when no feedback exists' do
      expect(helper.feedback_button_label(nil)).to eq('Leave Feedback')
    end

    it 'returns "Update Feedback" when feedback is present' do
      feedback = build(:event_feedback)
      expect(helper.feedback_button_label(feedback)).to eq('Update Feedback')
    end
  end

  describe '#feedback_modal_title' do
    it 'returns appropriate title for new feedback' do
      expect(helper.feedback_modal_title(nil)).to eq('Leave Feedback')
    end

    it 'returns update title when feedback exists' do
      feedback = build(:event_feedback)
      expect(helper.feedback_modal_title(feedback)).to eq('Update Your Feedback')
    end
  end
end

