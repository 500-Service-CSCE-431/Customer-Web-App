# frozen_string_literal: true

require 'csv'

class CalendarsController < ApplicationController
  before_action :authenticate_admin!, except: %i[home show about]
  before_action :require_admin!, only: %i[new create edit update delete destroy]

  def home
    @current_date = parse_current_date
    setup_calendar_view
    load_user_dashboard_data if user_signed_in?
  end

  def show
    @calendar = Calendar.find(params[:id])
    return unless user_signed_in?

    @event_feedback = @calendar.event_feedbacks.find_by(admin: current_user)
  end

  def about
    # About page - no authentication required
  end

  def export
    @calendar = Calendar.find(params[:id])
    require_admin!

    respond_to do |format|
      format.csv do
        send_data generate_csv,
                  filename: "#{@calendar.title.parameterize}_signups_#{Date.current.strftime('%Y%m%d')}.csv"
      end
    end
  end

  #----------------------------------------------------------------------------#
  def new
    @calendar = Calendar.new
  end

  def create
    @calendar = Calendar.new(calendar_params)

    if @calendar.save
      handle_successful_create
    else
      handle_failed_create
    end
  end
  #----------------------------------------------------------------------------#

  #----------------------------------------------------------------------------#
  def edit
    @calendar = Calendar.find(params[:id])
  end

  def update
    @calendar = Calendar.find(params[:id])

    if @calendar.update(calendar_params)
      flash[:notice] = 'Calendar event updated.'
      redirect_to home_path
    else
      render :edit, status: :unprocessable_entity
    end
  end
  #----------------------------------------------------------------------------#

  #----------------------------------------------------------------------------#
  def destroy
    @calendar = Calendar.find(params[:id])
    @calendar.destroy
    flash[:notice] = 'Calendar event deleted successfully!'
    redirect_to home_path
  end
  #----------------------------------------------------------------------------#

  private

  def calendar_params
    params.require(:calendar).permit(:title, :event_date, :description, :location, :category)
  end

  def generate_csv
    require 'csv'

    CSV.generate do |csv|
      add_event_details_to_csv(csv)
      add_signups_to_csv(csv)
    end
  end

  def parse_current_date
    return Date.parse("#{params[:date]}-01") if params[:date].present?

    Date.current
  end

  def setup_calendar_view
    month_start = @current_date.beginning_of_month
    month_end = @current_date.end_of_month
    calendar_start = month_start.beginning_of_week(:sunday)
    calendar_end = month_end.end_of_week(:sunday)

    @events = load_filtered_events(calendar_start, calendar_end)
    @calendar_days = build_calendar_days(calendar_start, calendar_end)
    @available_categories = ['Service', 'Bush School', 'Social']
  end

  def load_filtered_events(calendar_start, calendar_end)
    events = Calendar.where(event_date: calendar_start..calendar_end)
    @selected_categories = params[:categories] || []
    return events unless @selected_categories.present? && @selected_categories.any?(&:present?)

    events.where(category: @selected_categories)
  end

  def build_calendar_days(calendar_start, calendar_end)
    calendar_days = []
    current_date = calendar_start

    while current_date <= calendar_end
      calendar_days << build_calendar_day(current_date)
      current_date += 1.day
    end

    calendar_days
  end

  def build_calendar_day(current_date)
    day_events = @events.select { |event| event.event_date.to_date == current_date }
    {
      date: current_date,
      events: day_events,
      other_month: current_date.month != @current_date.month,
      today: current_date == Date.current
    }
  end

  def load_user_dashboard_data
    @past_events = load_past_events
    @upcoming_events = load_upcoming_events
  end

  def load_past_events
    current_user.signed_up_events
                .where('event_date < ?', Time.current)
                .order(event_date: :desc)
                .limit(10)
  end

  def load_upcoming_events
    current_user.signed_up_events
                .where('event_date >= ?', Time.current)
                .order(:event_date)
                .limit(10)
  end

  def handle_successful_create
    flash[:notice] = 'Calendar Event Added!'
    redirect_to home_path
  end

  def handle_failed_create
    error_msg = build_error_message
    flash[:notice] = error_msg
    redirect_to new_calendar_url
  end

  def build_error_message
    if @calendar.errors.any?
      @calendar.errors.full_messages.join(', ')
    else
      'One or more fields not filled. Try again!'
    end
  end

  def add_event_details_to_csv(csv)
    csv << ['Event Details']
    csv << ['Title', @calendar.title]
    csv << ['Date', @calendar.event_date.strftime('%B %d, %Y at %I:%M %p')]
    csv << ['Category', @calendar.category]
    csv << ['Location', @calendar.location]
    csv << ['Description', @calendar.description]
    csv << []
  end

  def add_signups_to_csv(csv)
    csv << ['Signups']
    csv << ['Name', 'Email', 'Signed Up At']
    @calendar.signups.includes(:admin).each do |signup|
      csv << [
        signup.admin.full_name,
        signup.admin.email,
        signup.created_at.strftime('%B %d, %Y at %I:%M %p')
      ]
    end
  end
  #----------------------------------------------------------------------------#
end
