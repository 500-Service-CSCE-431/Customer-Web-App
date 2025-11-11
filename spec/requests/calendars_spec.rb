# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Calendars', type: :request do
  describe 'GET /calendars/home' do
    it 'returns http success for unauthenticated users' do
      get home_path
      expect(response).to have_http_status(:success)
    end

    it 'loads calendar view with events' do
      create(:calendar, event_date: 1.day.from_now, title: 'Future Event')
      get home_path
      expect(response).to have_http_status(:success)
    end

    it 'filters events by category' do
      create(:calendar, category: 'Service', event_date: 1.day.from_now)
      create(:calendar, category: 'Social', event_date: 1.day.from_now)
      get home_path, params: { categories: ['Service'] }
      expect(response).to have_http_status(:success)
    end

    it 'handles date parameter for navigation' do
      get home_path, params: { date: '2024-12' }
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /calendars/:id' do
    let(:calendar) { create(:calendar) }

    it 'returns http success for unauthenticated users' do
      get show_calendar_path(calendar)
      expect(response).to have_http_status(:success)
    end

    it 'loads event feedback for signed in users' do
      admin = create(:admin)
      sign_in admin, scope: :admin
      get show_calendar_path(calendar)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /about' do
    it 'returns http success' do
      get about_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /calendars/:id/export' do
    let(:admin) { create(:admin, :admin_role) }
    let(:calendar) { create(:calendar) }
    let!(:signup) { create(:signup, calendar: calendar, admin: create(:admin)) }

    before do
      sign_in admin, scope: :admin
    end

    it 'exports calendar as CSV' do
      get export_calendar_path(calendar, format: :csv)
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('text/csv')
      expect(response.body).to include(calendar.title)
    end
  end

  describe 'POST /calendars' do
    let(:admin) { create(:admin, :admin_role) }

    before do
      sign_in admin, scope: :admin
    end

    it 'creates a new calendar event' do
      expect do
        post calendars_path, params: {
          calendar: {
            title: 'New Event',
            event_date: 1.day.from_now,
            description: 'Event description',
            location: 'Location',
            category: 'Service'
          }
        }
      end.to change(Calendar, :count).by(1)
      expect(response).to redirect_to(home_path)
    end

    it 'handles validation errors' do
      post calendars_path, params: {
        calendar: {
          title: '',
          event_date: nil,
          description: '',
          category: ''
        }
      }
      expect(response).to redirect_to(new_calendar_path)
    end
  end

  describe 'PATCH /calendars/:id' do
    let(:admin) { create(:admin, :admin_role) }
    let(:calendar) { create(:calendar) }

    before do
      sign_in admin, scope: :admin
    end

    it 'updates calendar event' do
      patch update_calendar_path(calendar), params: {
        calendar: {
          title: 'Updated Title',
          event_date: 2.days.from_now,
          description: 'Updated description',
          location: 'Updated location',
          category: 'Social'
        }
      }
      expect(response).to redirect_to(home_path)
      calendar.reload
      expect(calendar.title).to eq('Updated Title')
    end

    it 'handles validation errors on update' do
      patch update_calendar_path(calendar), params: {
        calendar: {
          title: '',
          event_date: nil
        }
      }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'DELETE /calendars/:id' do
    let(:admin) { create(:admin, :admin_role) }
    let!(:calendar) { create(:calendar) }

    before do
      sign_in admin, scope: :admin
    end

    it 'deletes calendar event' do
      expect do
        delete destroy_calendar_path(calendar)
      end.to change(Calendar, :count).by(-1)
      expect(response).to redirect_to(home_path)
    end
  end

  describe 'GET /calendars/new' do
    let(:admin) { create(:admin, :admin_role) }

    before do
      sign_in admin, scope: :admin
    end

    it 'returns http success' do
      get new_calendar_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /calendars/:id/edit' do
    let(:admin) { create(:admin, :admin_role) }
    let(:calendar) { create(:calendar) }

    before do
      sign_in admin, scope: :admin
    end

    it 'returns http success' do
      get edit_calendar_path(calendar)
      expect(response).to have_http_status(:success)
    end
  end
end

