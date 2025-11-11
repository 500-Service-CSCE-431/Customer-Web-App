# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe 'validations' do
    it 'is valid with the default factory' do
      expect(build(:admin)).to be_valid
    end

    it 'enforces role inclusion' do
      admin = build(:admin, role: 'invalid')
      expect(admin).not_to be_valid
      expect(admin.errors[:role]).to include('is not included in the list')
    end
  end

  describe '#admin?' do
    it 'returns true when role is admin' do
      admin = build(:admin, role: 'admin')
      expect(admin.admin?).to be true
    end

    it 'returns false when role is member' do
      admin = build(:admin, role: 'member')
      expect(admin.admin?).to be false
    end
  end

  describe '#member?' do
    it 'returns true when role is member' do
      admin = build(:admin, role: 'member')
      expect(admin.member?).to be true
    end

    it 'returns false when role is admin' do
      admin = build(:admin, role: 'admin')
      expect(admin.member?).to be false
    end
  end

  describe '.from_google' do
    let(:google_data) do
      {
        email: 'user@example.com',
        full_name: 'OAuth User',
        uid: 'google-uid-123',
        avatar_url: 'https://example.com/avatar.png'
      }
    end

    it 'creates a new member with the provided data' do
      admin = described_class.from_google(**google_data)

      expect(admin).to be_persisted
      expect(admin.email).to eq('user@example.com')
      expect(admin.full_name).to eq('OAuth User')
      expect(admin.role).to eq('member')
    end

    it 'updates an existing record with fresh details' do
      existing = create(:admin, :admin_role, email: 'user@example.com', full_name: 'Old Name', uid: 'old-uid', avatar_url: 'old.png')

      updated = described_class.from_google(**google_data)

      expect(updated.id).to eq(existing.id)
      expect(updated.full_name).to eq('OAuth User')
      expect(updated.uid).to eq('google-uid-123')
      expect(updated.avatar_url).to eq('https://example.com/avatar.png')
    end
  end
end
