# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Organization', type: :request do
  let(:admin) { create(:admin) }

  before do
    sign_in admin, scope: :admin
  end

  describe 'GET /organization' do
    it 'returns http success' do
      get organization_path
      expect(response).to have_http_status(:success)
    end
  end
end

