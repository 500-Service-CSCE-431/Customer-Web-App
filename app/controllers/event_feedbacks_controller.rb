# frozen_string_literal: true

class EventFeedbacksController < ApplicationController
  before_action :set_calendar, only: :create
  before_action :require_admin!, only: :index

  def create
    unless eligible_for_feedback?(@calendar)
      redirect_to show_calendar_path(@calendar), alert: 'You can only leave feedback for events you attended after they have occurred.'
      return
    end

    feedback = @calendar.event_feedbacks.find_or_initialize_by(admin: current_user)
    feedback.comments = feedback_params[:comments]
    feedback.submitted_at = Time.current

    if feedback.save
      redirect_to show_calendar_path(@calendar), notice: 'Thanks for sharing your feedback!'
    else
      redirect_to show_calendar_path(@calendar), alert: feedback.errors.full_messages.to_sentence
    end
  end

  def index
    @selected_month = (params[:month] || Date.current.month).to_i
    @selected_year = (params[:year] || Date.current.year).to_i

    begin
      range_start = Date.new(@selected_year, @selected_month, 1)
    rescue ArgumentError
      range_start = Date.current.beginning_of_month
      @selected_month = range_start.month
      @selected_year = range_start.year
    end

    range_end = range_start.end_of_month

    @events = Calendar
              .where(event_date: range_start..range_end)
              .includes(event_feedbacks: :admin)
              .order(:event_date)
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
end

