# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    # Always redirect to the public calendar
    redirect_to home_path
  end
end
