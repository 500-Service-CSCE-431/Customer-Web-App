# frozen_string_literal: true

class AdminManagementController < ApplicationController
  before_action :authenticate_admin!
  before_action :require_admin!

  def index
    @admins = Admin.all.order(:email)
  end

  def create_admin
    email = normalize_email(params[:email])
    return handle_blank_email if email.blank?
    return handle_existing_admin(email) if admin_exists?(email)
    return handle_invalid_email(email) unless valid_email_format?(email)

    create_new_admin(email)
    redirect_to admin_management_path
  end

  def remove_admin
    admin = Admin.find(params[:id])
    return handle_cannot_remove_last_admin if last_admin?
    return handle_cannot_remove_self(admin) if admin == current_admin

    remove_admin_safely(admin)
    redirect_to admin_management_path
  end

  private

  def normalize_email(email)
    email&.strip&.downcase
  end

  def admin_exists?(email)
    Admin.exists?(['LOWER(email) = ?', email])
  end

  def valid_email_format?(email)
    email.match?(/\A[\w+\-.]+@[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\z/i)
  end

  def last_admin?
    Admin.count <= 1
  end

  def handle_blank_email
    flash[:alert] = 'Email cannot be blank.'
    redirect_to admin_management_path
  end

  def handle_existing_admin(email)
    flash[:alert] = "Admin with email #{email} already exists."
    redirect_to admin_management_path
  end

  def handle_invalid_email(_email)
    flash[:alert] = 'Invalid email format.'
    redirect_to admin_management_path
  end

  def create_new_admin(email)
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

  def handle_cannot_remove_last_admin
    flash[:alert] = 'Cannot remove the last admin.'
    redirect_to admin_management_path
  end

  def handle_cannot_remove_self(_admin)
    flash[:alert] = 'You cannot remove yourself as an admin.'
    redirect_to admin_management_path
  end

  def remove_admin_safely(admin)
    email = admin.email
    admin.destroy
    flash[:success] = "Admin #{email} has been removed successfully."
  end
end
