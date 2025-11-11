# frozen_string_literal: true

module Admins
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    def google_oauth2
      admin = Admin.from_google(**from_google_params)
      return handle_auth_failure unless admin.present?

      handle_successful_auth(admin)
    end

    protected

    def after_omniauth_failure_path_for(_scope)
      root_path
    end

    def after_sign_in_path_for(resource_or_scope)
      stored_location_for(resource_or_scope) || home_path
    end

    private

    def from_google_params
      @from_google_params ||= {
        uid: auth.uid,
        email: auth.info.email,
        full_name: auth.info.name,
        avatar_url: auth.info.image
      }
    end

    def auth
      @auth ||= request.env['omniauth.auth']
    end

    def handle_successful_auth(admin)
      sign_out_all_scopes
      flash[:success] = welcome_message(admin)
      sign_in_and_redirect admin, event: :authentication
    end

    def welcome_message(admin)
      if admin.admin?
        "Welcome back, #{admin.full_name}! You're signed in as an admin."
      else
        "Welcome #{admin.full_name}! You're signed in as a member."
      end
    end

    def handle_auth_failure
      flash[:error] = 'Authentication failed. Please try again.'
      redirect_to new_admin_session_path
    end
  end
end
