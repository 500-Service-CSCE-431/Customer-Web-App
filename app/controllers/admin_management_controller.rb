# frozen_string_literal: true

class AdminManagementController < ApplicationController
  before_action :authenticate_admin!
  before_action :require_admin!

  def index
    @admins = Admin.all.order(:email)
  end

  def create_admin
    email = params[:email]&.strip&.downcase

    if email.blank?
      flash[:alert] = 'Email cannot be blank.'
      redirect_to admin_management_path and return
    end

    # Check if admin already exists
    if Admin.exists?(['LOWER(email) = ?', email])
      flash[:alert] = "Admin with email #{email} already exists."
      redirect_to admin_management_path and return
    end

    # Validate email format
    unless email.match?(/\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i)
      flash[:alert] = 'Invalid email format.'
      redirect_to admin_management_path and return
    end

    # Create new admin
    begin
      Admin.create!(
        email: email,
        full_name: email.split('@').first.titleize,
        uid: SecureRandom.hex(10),
        encrypted_password: 'pending_oauth',
        role: 'admin'
      )
      flash[:success] = "Admin #{email} has been added successfully."
    rescue StandardError => e
      flash[:alert] = "Error creating admin: #{e.message}"
    end

    redirect_to admin_management_path
  end

  def remove_admin
    admin = Admin.find(params[:id])

    # Prevent removing the last admin
    if Admin.count <= 1
      flash[:alert] = 'Cannot remove the last admin.'
      redirect_to admin_management_path and return
    end

    # Prevent admin from removing themselves
    if admin == current_admin
      flash[:alert] = 'You cannot remove yourself as an admin.'
      redirect_to admin_management_path and return
    end

    email = admin.email
    admin.destroy
    flash[:success] = "Admin #{email} has been removed successfully."
    redirect_to admin_management_path
  end
end
