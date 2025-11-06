# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # Require authentication for all controllers by default
  before_action :authenticate_admin!

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Helper method to check if current user is an admin
  def admin_user?
    current_admin&.admin?
  end
  helper_method :admin_user?

  # Helper method to check if current user is a member
  def member_user?
    current_admin&.member?
  end
  helper_method :member_user?

  # Helper method to require admin privileges
  def require_admin!
    return if admin_user?

    flash[:alert] = 'You must be an admin to access this page.'
    redirect_to home_path
  end

  # Helper method to get current user info (now using the admin model)
  def current_user
    current_admin
  end
  helper_method :current_user

  # Helper method to check if user is signed in (now using admin model)
  def user_signed_in?
    admin_signed_in?
  end
  helper_method :user_signed_in?

  # Helper method to check if current user is signed up for an event
  def signed_up_for?(event)
    return false unless user_signed_in?

    current_user.signed_up_events.include?(event)
  end
  helper_method :signed_up_for?
end
