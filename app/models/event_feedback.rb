# frozen_string_literal: true

class EventFeedback < ApplicationRecord
  belongs_to :calendar
  belongs_to :admin

  validates :comments, presence: true, length: { maximum: 2000 }
  validates :submitted_at, presence: true
  validates :admin_id, uniqueness: { scope: :calendar_id, message: 'has already submitted feedback for this event' }

  scope :ordered, -> { order(submitted_at: :desc) }
end

