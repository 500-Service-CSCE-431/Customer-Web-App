# frozen_string_literal: true

class OrganizationController < ApplicationController
  before_action :require_sign_in

  def index
    @admins = Admin.where(role: 'admin').order(:full_name)
    @members = Admin.where(role: 'member').order(:full_name)
  end

  private

  def require_sign_in
    redirect_to home_path, alert: 'You must sign in to view the organization directory.' unless admin_signed_in?
  end
end
