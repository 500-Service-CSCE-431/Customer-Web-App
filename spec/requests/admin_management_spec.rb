# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'AdminManagements', type: :request do
  let(:admin_user) { create(:admin, :admin_role) }

  before do
    sign_in admin_user, scope: :admin
  end

  describe 'GET /admin_management' do
    it 'returns http success' do
      get admin_management_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /admin_management/create_admin' do
    it 'creates a new admin and redirects' do
      new_email = 'newadmin@example.com'
      expect do
        post create_admin_path, params: { email: new_email }
      end.to change(Admin, :count).by(1)
      expect(response).to redirect_to(admin_management_path)
      expect(Admin.find_by(email: new_email)).to be_present
    end

    it 'rejects blank email' do
      expect do
        post create_admin_path, params: { email: '' }
      end.not_to change(Admin, :count)
      expect(response).to redirect_to(admin_management_path)
    end
  end

  describe 'DELETE /admin_management/remove_admin/:id' do
    let!(:other_admin) { create(:admin, :admin_role) }

    it 'removes an admin and redirects' do
      expect do
        delete remove_admin_path(other_admin)
      end.to change(Admin, :count).by(-1)
      expect(response).to redirect_to(admin_management_path)
    end

    it 'prevents removing the last admin' do
      Admin.where.not(id: admin_user.id).destroy_all
      expect do
        delete remove_admin_path(admin_user)
      end.not_to change(Admin, :count)
      expect(response).to redirect_to(admin_management_path)
    end
  end
end
