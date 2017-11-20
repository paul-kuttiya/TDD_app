source 'https://rubygems.org'

ruby '2.2.7'

gem 'rails', '4.2.2'
gem 'sqlite3'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'haml'

gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc

gem 'puma'
gem 'bootstrap-sass', '~> 3.3.4'
gem 'simple_form', '~> 3.1.0'

# upload file
gem 'carrierwave'

# use for render markdown as form input
gem 'redcarpet', '~> 3.2.3'

# user auth
gem 'devise', '~> 3.4.1'

gem 'twitter', '~> 5.15.0'

# serialize json for response
gem 'active_model_serializers'

group :development do
  gem 'web-console', '~> 2.0'
end

group :development, :test do
  gem 'byebug'
  # keep rails running without reboot
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-cucumber'
  gem 'rspec-rails', '~> 3.5'

  # fabricate tests and seed object
  gem 'factory_girl_rails', '~> 4.5.0'
  gem 'pry'
end

group :test do
  gem 'capybara', '~> 2.4.4'
  # capybara save_and_open_page
  gem 'launchy'
  gem 'cucumber-rails', '~> 1.4.2', require: false
  gem 'database_cleaner'
  gem 'shoulda-matchers', '~> 2.7.0', require: false

  # record api
  gem 'vcr', '3.0.3'
  gem 'webmock'
end