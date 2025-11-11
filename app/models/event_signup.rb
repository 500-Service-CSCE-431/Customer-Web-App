# frozen_string_literal: true

class EventSignup < ApplicationRecord
  belongs_to :calendar

  validates :user_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :user_name, presence: true
  validates :user_email, uniqueness: { scope: :calendar_id, message: 'has already signed up for this event' }

  scope :for_user, ->(email) { where(user_email: email) }
  scope :upcoming, -> { joins(:calendar).where('calendars.event_date > ?', Time.current) }
end
