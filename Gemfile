source "https://rubygems.org"

ruby "3.3.9"

# Rails and core stack
gem "rails", "~> 8.0.2", ">= 8.0.2.1"
gem "propshaft"
gem "puma", ">= 5.0"
gem "bootsnap", require: false
gem "rexml"

# Front-end/bundling
# If you are no longer using Importmap, you may remove this gem later.
gem "importmap-rails"
gem "jsbundling-rails"
gem "cssbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"

# Caching / jobs / cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Utilities
gem "rqrcode", "~> 2.2"

# Deployment & perf helpers
gem "kamal", require: false
gem "thruster", require: false

# JSON builder (optional)
gem "jbuilder", "~> 2.7"

# Database adapters
gem "pg", "~> 1.5"   # PostgreSQL for all environments

# Windows time zone data
gem "tzinfo-data", platforms: %i[windows jruby]

# Linting
gem "rubocop", require: false

gem 'devise'
gem 'omniauth'
gem 'omniauth-google-oauth2'
gem 'omniauth-rails_csrf_protection'

group :development, :test do

  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false

  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails"
  gem "faker"
  gem "capybara"
  gem "rubocop-rails-omakase",  require: false
  gem "rubocop-rails",          require: false
  gem "rubocop-performance",    require: false
  gem "rubocop-rspec",          require: false
  gem "rubocop-rake",           require: false
  gem "rubocop-capybara",       require: false
end

group :development do
  gem "web-console"
end

group :test do
  gem "selenium-webdriver"
  gem "webdrivers"
  gem "simplecov", require: false
end
