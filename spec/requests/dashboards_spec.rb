# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Dashboards', type: :request do
  let(:admin) { create(:admin) }

  before do
    sign_in admin, scope: :admin
  end

  describe 'GET /dashboard' do
    it 'returns http success' do
      get dashboard_path
      expect(response).to have_http_status(:success)
    end
  end
end

