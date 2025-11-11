# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin, '.from_google' do
  describe 'when admin does not exist' do
    it 'creates a new admin with member role' do
      expect do
        Admin.from_google(
          email: 'newuser@example.com',
          full_name: 'New User',
          uid: '123456789',
          avatar_url: 'https://example.com/avatar.jpg'
        )
      end.to change(Admin, :count).by(1)

      admin = Admin.find_by(email: 'newuser@example.com')
      expect(admin).to be_present
      expect(admin.full_name).to eq('New User')
      expect(admin.uid).to eq('123456789')
      expect(admin.avatar_url).to eq('https://example.com/avatar.jpg')
      expect(admin.role).to eq('member')
    end
  end

  describe 'when admin exists' do
    let!(:existing_admin) do
      create(:admin, email: 'existing@example.com', uid: 'old_uid', full_name: 'Old Name')
    end

    it 'updates existing admin with new OAuth data' do
      result = Admin.from_google(
        email: 'existing@example.com',
        full_name: 'Updated Name',
        uid: 'new_uid',
        avatar_url: 'https://example.com/new_avatar.jpg'
      )

      expect(result).to eq(existing_admin)
      existing_admin.reload
      expect(existing_admin.full_name).to eq('Updated Name')
      expect(existing_admin.uid).to eq('new_uid')
      expect(existing_admin.avatar_url).to eq('https://example.com/new_avatar.jpg')
    end

    it 'does not change the admin count' do
      expect do
        Admin.from_google(
          email: 'existing@example.com',
          full_name: 'Updated Name',
          uid: 'new_uid',
          avatar_url: 'https://example.com/new_avatar.jpg'
        )
      end.not_to change(Admin, :count)
    end
  end
end

