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
gem 'bootstrap-sass'
gem 'simple_form'

# use for render markdown as form input
gem 'redcarpet'

# user auth
gem 'devise'

group :development, :test do
  gem 'byebug'
  gem 'web-console', '~> 2.0'
  # keep rails running without reboot
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-cucumber'
  gem 'rspec-rails', '~> 3.5'

  # fabricate tests and seed object
  gem 'factory_girl_rails'
  gem 'pry'
end

group :test do
  gem 'capybara'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
end