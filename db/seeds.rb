# frozen_string_literal: true

require 'securerandom'

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

if Rails.env.development?
  # DEVELOPMENT ENVIRONMENT - Sample Calendar Events and Admin
  puts 'Seeding development environment with sample calendar events and admin...'

  # Create admin user for development
  admin = Admin.find_by('LOWER(email) = LOWER(?)', 'isaacgeng@tamu.edu')
  if admin
    admin.update!(role: 'admin') if admin.role.blank?
    puts 'Admin user already exists: isaacgeng@tamu.edu'
  else
    Admin.create!(email: 'isaacgeng@tamu.edu', full_name: 'Isaac Geng', uid: '102717360320592949627',
                  encrypted_password: 'oauth_user', role: 'admin')
    puts 'Admin user created: isaacgeng@tamu.edu'
  end

  # Create calendar events for development (using future dates)
  Calendar.find_or_create_by!(title: 'Community Service Event') do |calendar|
    calendar.event_date = DateTime.new(2025, 12, 15, 14, 0, 0)
    calendar.description = 'Weekly team standup meeting to discuss project progress and upcoming deadlines'
    calendar.location = 'Conference Room A'
    calendar.category = 'Service'
  end

  Calendar.find_or_create_by!(title: 'Bush School Lecture') do |calendar|
    calendar.event_date = DateTime.new(2025, 12, 20, 17, 0, 0)
    calendar.description = 'Guest lecture on public policy and governance'
    calendar.location = 'Bush School Auditorium'
    calendar.category = 'Bush School'
  end

  Calendar.find_or_create_by!(title: 'Social Mixer') do |calendar|
    calendar.event_date = DateTime.new(2025, 12, 25, 10, 30, 0)
    calendar.description = 'Networking event for students and alumni'
    calendar.location = 'Student Center'
    calendar.category = 'Social'
  end

  Calendar.find_or_create_by!(title: 'Policy Workshop') do |calendar|
    calendar.event_date = DateTime.new(2026, 1, 5, 15, 0, 0)
    calendar.description = 'Workshop on policy analysis and implementation'
    calendar.location = 'Bush School - Room 101'
    calendar.category = 'Bush School'
  end

  Calendar.find_or_create_by!(title: 'Volunteer Cleanup') do |calendar|
    calendar.event_date = DateTime.new(2026, 1, 10, 9, 0, 0)
    calendar.description = 'Community park cleanup volunteer event'
    calendar.location = 'City Park'
    calendar.category = 'Service'
  end

  # Seed a past event for feedback testing
  feedback_tester = Admin.find_or_create_by!(email: 'isaacgeng2004@gmail.com') do |admin|
    admin.full_name = 'Isaac Geng (Member)'
    admin.role = 'member'
    admin.uid = SecureRandom.uuid
    admin.encrypted_password = 'oauth_user'
  end

  past_event = Calendar.find_or_initialize_by(title: 'Past Feedback Test Event')
  past_event.assign_attributes(
    event_date: 2.weeks.ago.change(hour: 18, min: 0),
    description: 'Seeded event in the past for validating the feedback workflow.',
    location: 'Development Lab',
    category: 'Social'
  )
  past_event.save!(validate: false)

  Signup.find_or_initialize_by(calendar: past_event, admin: feedback_tester).tap do |signup|
    signup.save!(validate: false)
  end

  puts 'Development data created successfully! (5 sample calendar events)'

elsif Rails.env.test?
  # TEST ENVIRONMENT - Test Calendar Events
  puts 'Seeding test environment with test calendar events...'

  # Create calendar events for test (using future dates)
  Calendar.find_or_create_by!(title: 'Test Service Event') do |calendar|
    calendar.event_date = DateTime.new(2025, 1, 10, 9, 0, 0)
    calendar.description = 'Test event for automated testing'
    calendar.location = 'Test Room'
    calendar.category = 'Service'
  end

  Calendar.find_or_create_by!(title: 'Test Bush School Event') do |calendar|
    calendar.event_date = DateTime.new(2025, 1, 12, 14, 0, 0)
    calendar.description = 'Test Bush School event'
    calendar.location = 'Bush School'
    calendar.category = 'Bush School'
  end

  puts 'Test data created successfully! (2 test calendar events)'

else
  # PRODUCTION ENVIRONMENT - Production Calendar Events and Admin
  puts 'Seeding production environment with production calendar events and admin...'

  # Create admin user for production
  admin = Admin.find_by('LOWER(email) = LOWER(?)', 'isaacgeng@tamu.edu')
  if admin
    admin.update!(role: 'admin') if admin.role != 'admin'
    puts 'Admin user already exists: isaacgeng@tamu.edu'
  else
    Admin.create!(email: 'isaacgeng@tamu.edu', full_name: 'Isaac Geng', uid: '102717360320592949627',
                  encrypted_password: 'oauth_user', role: 'admin')
    puts 'Admin user created: isaacgeng@tamu.edu'
  end

  # Create calendar events for production (using future dates)
  Calendar.find_or_create_by!(title: 'WIPS Service Day') do |calendar|
    calendar.event_date = DateTime.new(2025, 3, 15, 20, 0, 0)
    calendar.description = 'Annual community service day event'
    calendar.location = 'Various Locations'
    calendar.category = 'Service'
  end

  Calendar.find_or_create_by!(title: 'Bush School Symposium') do |calendar|
    calendar.event_date = DateTime.new(2025, 4, 10, 11, 0, 0)
    calendar.description = 'Annual policy symposium featuring guest speakers'
    calendar.location = 'Bush School Auditorium'
    calendar.category = 'Bush School'
  end

  puts 'Production data created successfully! (2 production calendar events)'
end
