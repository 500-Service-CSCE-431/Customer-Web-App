# frozen_string_literal: true

class EventFeedbacksController < ApplicationController
  before_action :set_calendar, only: :create
  before_action :require_admin!, only: :index

  def create
    return handle_feedback_ineligible unless eligible_for_feedback?(@calendar)

    save_feedback
  end

  def index
    date_range = parse_date_range
    @events = load_events_for_month(date_range[:start], date_range[:end])
  end

  private

  def set_calendar
    @calendar = Calendar.find(params[:calendar_id])
  end

  def feedback_params
    params.require(:event_feedback).permit(:comments)
  end

  def eligible_for_feedback?(calendar)
    return false unless user_signed_in?
    return false unless calendar.event_date.past?

    calendar.signups.exists?(admin_id: current_user.id)
  end

  def handle_feedback_ineligible
    redirect_to show_calendar_path(@calendar),
                alert: 'You can only leave feedback for events you attended after they have occurred.'
  end

  def save_feedback
    feedback = @calendar.event_feedbacks.find_or_initialize_by(admin: current_user)
    feedback.comments = feedback_params[:comments]
    feedback.submitted_at = Time.current

    if feedback.save
      redirect_to show_calendar_path(@calendar), notice: 'Thanks for sharing your feedback!'
    else
      redirect_to show_calendar_path(@calendar), alert: feedback.errors.full_messages.to_sentence
    end
  end

  def parse_date_range
    @selected_month = parse_month_param
    @selected_year = parse_year_param
    range_start = calculate_range_start

    { start: range_start, end: range_start.end_of_month }
  end

  def parse_month_param
    (params[:month] || Date.current.month).to_i
  end

  def parse_year_param
    (params[:year] || Date.current.year).to_i
  end

  def calculate_range_start
    Date.new(@selected_year, @selected_month, 1)
  rescue ArgumentError
    set_current_month_as_default
    Date.current.beginning_of_month
  end

  def set_current_month_as_default
    range_start = Date.current.beginning_of_month
    @selected_month = range_start.month
    @selected_year = range_start.year
  end

  def load_events_for_month(range_start, range_end)
    Calendar
      .where(event_date: range_start..range_end)
      .includes(event_feedbacks: :admin)
      .order(:event_date)
  end
end
