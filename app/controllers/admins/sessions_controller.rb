# frozen_string_literal: true

module Admins
  class SessionsController < Devise::SessionsController
    # Skip authentication for sign out action
    skip_before_action :authenticate_admin!, only: [:destroy]

    # Where to go after logging out
    def after_sign_out_path_for(_resource_or_scope)
      root_path
    end

    # Where to go after logging in
    def after_sign_in_path_for(resource_or_scope)
      stored_location_for(resource_or_scope) || home_path
    end
  end
end
