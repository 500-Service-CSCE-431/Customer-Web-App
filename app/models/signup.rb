# frozen_string_literal: true

class Signup < ApplicationRecord
  belongs_to :admin
  belongs_to :calendar

  # Ensure a user can only sign up for an event once
  validates :admin_id, uniqueness: { scope: :calendar_id, message: 'has already signed up for this event' }

  # Ensure the event hasn't already passed
  validate :event_not_in_past

  private

  def event_not_in_past
    return unless calendar&.event_date && calendar.event_date < Time.current

    errors.add(:calendar, 'cannot sign up for events that have already occurred')
  end
end
