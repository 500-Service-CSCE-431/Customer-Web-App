# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AdminManagements', type: :request do
  describe 'GET /index' do
    it 'returns http success' do
      get '/admin_management/index'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /create_admin' do
    it 'returns http success' do
      get '/admin_management/create_admin'
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET /remove_admin' do
    it 'returns http success' do
      get '/admin_management/remove_admin'
      expect(response).to have_http_status(:success)
    end
  end
end
