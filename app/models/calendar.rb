# frozen_string_literal: true

class Calendar < ApplicationRecord
  has_many :signups, dependent: :destroy
  has_many :signed_up_users, through: :signups, source: :admin
  has_many :event_feedbacks, dependent: :destroy

  validates :title, presence: true
  validates :event_date, presence: true
  validates :description, presence: true
  validates :category, presence: true, inclusion: { in: ['Service', 'Bush School', 'Social'] }
  validate :event_date_must_be_in_future

  def signup_count
    event_signups.count
  end

  def user_signed_up?(user_email)
    event_signups.exists?(user_email: user_email)
  end

  private

  def event_date_must_be_in_future
    return unless event_date.present?
    return if event_date_valid?

    add_event_date_error
  end

  def event_date_valid?
    event_date_only = event_date.to_time.to_date
    current_date_only = Time.current.to_date
    yesterday_date = current_date_only - 1.day
    event_date_only >= yesterday_date
  end

  def add_event_date_error
    event_date_only = event_date.to_time.to_date
    date_str = event_date_only.strftime('%B %d, %Y')
    message = "must be from yesterday onwards. Selected date (#{date_str}) is too far in the past."
    errors.add(:event_date, message)
  end
end
