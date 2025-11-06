# frozen_string_literal: true

class Admin < ApplicationRecord
  devise :omniauthable, omniauth_providers: [:google_oauth2]

  has_many :signups, dependent: :destroy
  has_many :signed_up_events, through: :signups, source: :calendar

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
    # Find existing user or create new one
    admin = find_by('LOWER(email) = LOWER(?)', email)

    if admin
      # Update existing user with new OAuth data
      admin.update!(uid: uid, full_name: full_name, avatar_url: avatar_url)
      admin
    else
      # Create new user with default 'member' role
      create!(
        email: email,
        full_name: full_name,
        uid: uid,
        avatar_url: avatar_url,
        role: 'member'
      )
    end
  end
end
