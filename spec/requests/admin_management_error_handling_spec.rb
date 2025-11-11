# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AdminManagement Error Handling', type: :request do
  let(:admin_user) { create(:admin, :admin_role) }

  before do
    sign_in admin_user, scope: :admin
  end

  describe 'POST /admin_management/create_admin' do
    it 'handles invalid email format' do
      post create_admin_path, params: { email: 'invalid-email' }
      expect(flash[:alert]).to include('Invalid email format')
      expect(response).to redirect_to(admin_management_path)
    end

    it 'handles existing admin email' do
      existing_email = 'existing@example.com'
      create(:admin, email: existing_email)
      post create_admin_path, params: { email: existing_email }
      expect(flash[:alert]).to include('already exists')
      expect(response).to redirect_to(admin_management_path)
    end

    it 'handles creation errors' do
      allow(Admin).to receive(:create!).and_raise(StandardError.new('Database error'))
      post create_admin_path, params: { email: 'test@example.com' }
      expect(flash[:alert]).to include('Error creating admin')
    end
  end

  describe 'DELETE /admin_management/remove_admin/:id' do
    it 'prevents removing self' do
      # Create another admin so we're not the last admin
      other_admin = create(:admin, :admin_role)
      expect do
        delete remove_admin_path(admin_user)
      end.not_to change(Admin, :count)
      expect(flash[:alert]).to include('cannot remove yourself')
      expect(response).to redirect_to(admin_management_path)
    end
  end
end

