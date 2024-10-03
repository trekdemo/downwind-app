source "https://rubygems.org"

ruby "3.3.1"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.0.0.beta1"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use sqlite3 as the database for Active Record
gem "sqlite3", "~> 2.1"
# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Tailwind CSS [https://github.com/rails/tailwindcss-rails]
gem "tailwindcss-rails"
gem "material_icons"

gem "clearance", "~> 2.8"

gem "geocoder"
gem "gpx"

gem "fast-polylines", "~> 2.2"
gem "mapkick-rb", "~> 0.1.5"

gem "daru", "~> 0.3", require: false
gem "matrix", "~> 0.4.2", require: false

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "active_storage_validations"
# gem "image_processing", "~> 1.2"

# An attempt to tame Rails' default policy to log everything.
gem "lograge"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows]
  gem "dotenv-rails"
  gem "hotwire-livereload", "~> 1.4"
  gem "rspec", "~> 3.13"
  gem "rspec-rails", "~> 7.0"
  gem "launchy"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"

  gem "rubocop-rails-omakase", require: false
  gem "strong_migrations", "~> 2.0"
end

group :test do
  gem "brakeman", "~> 6.1", require: false
  gem "rspec-github", require: false
  gem "capybara"
  gem "factory_bot_rails"
  gem "shoulda-matchers", "~> 6.0"
end
