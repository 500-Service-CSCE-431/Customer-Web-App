# frozen_string_literal: true

class Admin < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :signups, dependent: :destroy
  has_many :signed_up_events, through: :signups, source: :calendar
  has_many :event_feedbacks, dependent: :destroy

  # Role validations
  validates :role, presence: true, inclusion: { in: %w[member admin] }

  # Role helper methods
  def admin?
    role == 'admin'
  end

  def member?
    role == 'member'
  end

  def self.from_google(email:, full_name:, uid:, avatar_url:)
    admin = find_by('LOWER(email) = LOWER(?)', email)
    return update_existing_admin(admin, uid, full_name, avatar_url) if admin

    create_new_admin(email, full_name, uid, avatar_url)
  end

  def self.update_existing_admin(admin, uid, full_name, avatar_url)
    admin.update!(uid: uid, full_name: full_name, avatar_url: avatar_url)
    admin
  end

  def self.create_new_admin(email, full_name, uid, avatar_url)
    create!(
      email: email,
      full_name: full_name,
      uid: uid,
      avatar_url: avatar_url,
      role: 'member'
    )
  end
end
