# frozen_string_literal: true

class SignupsController < ApplicationController
  before_action :authenticate_admin!
  before_action :set_calendar

  def create
    @signup = current_admin.signups.build(calendar: @calendar)

    if @signup.save
      flash[:success] = "Successfully signed up for #{@calendar.title}!"
    else
      flash[:alert] = @signup.errors.full_messages.join(', ')
    end

    redirect_back(fallback_location: home_path)
  end

  def destroy
    @signup = current_admin.signups.find_by(calendar: @calendar)

    if @signup&.destroy
      flash[:success] = "Successfully signed out of #{@calendar.title}."
    else
      flash[:alert] = 'You are not signed up for this event.'
    end

    redirect_back(fallback_location: home_path)
  end

  private

  def set_calendar
    @calendar = Calendar.find(params[:calendar_id])
  end
end
