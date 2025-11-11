# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      admin = build(:admin)
      expect(admin).to be_valid
    end

    it 'validates role inclusion' do
      admin = build(:admin, role: 'invalid_role')
      expect(admin).not_to be_valid
      expect(admin.errors[:role]).to be_present
    end

    it 'validates role presence' do
      admin = build(:admin, role: nil)
      expect(admin).not_to be_valid
      expect(admin.errors[:role]).to be_present
    end
  end

  describe 'role methods' do
    it 'returns true for admin? when role is admin' do
      admin = build(:admin, :admin_role)
      expect(admin.admin?).to be true
    end

    it 'returns false for admin? when role is member' do
      admin = build(:admin, role: 'member')
      expect(admin.admin?).to be false
    end

    it 'returns true for member? when role is member' do
      admin = build(:admin, role: 'member')
      expect(admin.member?).to be true
    end

    it 'returns false for member? when role is admin' do
      admin = build(:admin, :admin_role)
      expect(admin.member?).to be false
    end
  end

  describe 'associations' do
    it 'has many signups' do
      admin = create(:admin)
      calendar = create(:calendar)
      signup = create(:signup, admin: admin, calendar: calendar)
      expect(admin.signups).to include(signup)
    end

    it 'has many signed_up_events through signups' do
      admin = create(:admin)
      calendar = create(:calendar)
      create(:signup, admin: admin, calendar: calendar)
      expect(admin.signed_up_events).to include(calendar)
    end
  end
end
