# frozen_string_literal: true

require 'csv'

class CalendarsController < ApplicationController
  before_action :authenticate_admin!, except: %i[home show about]
  before_action :require_admin!, only: %i[new create edit update delete destroy]

  def home
    # Handle date parameter for navigation
    @current_date = if params[:date].present?
                      Date.parse("#{params[:date]}-01")
                    else
                      Date.current
                    end

    # Get start and end of month
    month_start = @current_date.beginning_of_month
    month_end = @current_date.end_of_month

    # Get calendar start (beginning of week containing month start)
    calendar_start = month_start.beginning_of_week(:sunday)
    calendar_end = month_end.end_of_week(:sunday)

    # Get all events for the visible calendar period
    @events = Calendar.where(event_date: calendar_start..calendar_end)

    # Apply category filtering
    @selected_categories = params[:categories] || []
    if @selected_categories.present? && @selected_categories.any?(&:present?)
      @events = @events.where(category: @selected_categories)
    end

    # Build calendar days array
    @calendar_days = []
    current_date = calendar_start

    while current_date <= calendar_end
      day_events = @events.select { |event| event.event_date.to_date == current_date }

      @calendar_days << {
        date: current_date,
        events: day_events,
        other_month: current_date.month != @current_date.month,
        today: current_date == Date.current
      }

      current_date += 1.day
    end

    # Available categories for filtering
    @available_categories = ['Service', 'Bush School', 'Social']

    # Dashboard data for signed-in users
    return unless user_signed_in?

    # Past events user attended (events that have already occurred)
    @past_events = current_user.signed_up_events
                               .where('event_date < ?', Time.current)
                               .order(event_date: :desc)
                               .limit(10)

    # Future events user is signed up for
    @upcoming_events = current_user.signed_up_events
                                   .where('event_date >= ?', Time.current)
                                   .order(:event_date)
                                   .limit(10)
  end

  def show
    @calendar = Calendar.find(params[:id])
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
      flash[:notice] = 'Calendar Event Added!'
      redirect_to home_path
    else
      # Display specific validation errors if available, otherwise show generic message
      if @calendar.errors.any?
        error_messages = @calendar.errors.full_messages.join(', ')
        flash[:notice] = error_messages
      else
        flash[:notice] = 'One or more fields not filled. Try again!'
      end
      redirect_to new_calendar_url
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
      # Event details header
      csv << ['Event Details']
      csv << ['Title', @calendar.title]
      csv << ['Date', @calendar.event_date.strftime('%B %d, %Y at %I:%M %p')]
      csv << ['Category', @calendar.category]
      csv << ['Location', @calendar.location]
      csv << ['Description', @calendar.description]
      csv << [] # Empty row

      # Signups header
      csv << ['Signups']
      csv << ['Name', 'Email', 'Signed Up At']

      # Signup data
      @calendar.signups.includes(:admin).each do |signup|
        csv << [
          signup.admin.full_name,
          signup.admin.email,
          signup.created_at.strftime('%B %d, %Y at %I:%M %p')
        ]
      end
    end
  end
  #----------------------------------------------------------------------------#
end
