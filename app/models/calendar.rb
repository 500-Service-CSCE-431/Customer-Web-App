# frozen_string_literal: true

class Calendar < ApplicationRecord
  has_many :signups, dependent: :destroy
  has_many :signed_up_users, through: :signups, source: :admin

  validates :title, presence: true
  validates :event_date, presence: true
  validates :description, presence: true
  validates :category, presence: true, inclusion: { in: ['Service', 'Bush School', 'Social'] }
  validate :event_date_must_be_in_future

  def signed_up_users
    signups.includes(:admin)
  end

  def signup_count
    signups.count
  end

  def user_signed_up?(user_email)
    signups.joins(:admin).exists?(admins: { email: user_email })
  end

  private

  def event_date_must_be_in_future
    return unless event_date.present?

    # CRITICAL TIMEZONE ISSUE FIX:
    # datetime-local inputs have no timezone info, but represent user's local time
    # Rails server is in UTC, so date comparisons can fail due to timezone differences
    # Example: User in UTC-6 selects Nov 10 11:30 PM, but server sees Nov 11 in UTC
    # Solution: Allow events from "yesterday" (server time) onwards to handle timezone edge cases
    
    event_time = event_date.to_time
    current_time = Time.current
    
    # Compare dates (not times) to handle timezone differences
    event_date_only = event_time.to_date
    current_date_only = current_time.to_date
    yesterday_date = current_date_only - 1.day
    
    # Allow events from yesterday onwards (very permissive to handle timezone issues)
    # This allows users in timezones behind UTC to create events for "today" in their timezone
    # even if the server date is already "tomorrow" in UTC
    if event_date_only >= yesterday_date
      # Event is yesterday, today, or in the future - allow it
      return
    end
    
    # Only reject events that are clearly 2+ days in the past
    errors.add(:event_date, "must be from yesterday onwards. Selected date (#{event_date_only.strftime('%B %d, %Y')}) is too far in the past.")
  end
end
