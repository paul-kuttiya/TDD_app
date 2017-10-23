# TDD with Ruby on rails  

### Table of contents  
* [Project Inilization](#project-Inilization)
* [BDD test with Feature spec](#BDD-test-with-feature-spec)
* [First Feature spec: Happy Path](#first-feature-spec:-happy-path)


### Project Inilizaiton  
* Start project without unit test  
~> `rails _4.2_ new -T app_name`  

* Essential gems  
```ruby
gem 'puma'
gem 'bootstrap-sass'

group :development, :test do
  #if use spring
  gem 'spring'
  gem 'spring-commands-rspec'

  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :test do
  gem 'capybara'
end
```

* config bootstrap  
~> generate `main.sass` in `app/assets/stylesheets/main.sass`  
~> `@import 'bootstrap-sprockets'`  
~> `@import 'bootstrap'`  

* generate `rspec` files  
~> `rails g rspec:install`  

* [if use spring] generate spring files  
~> `bundle exec spring binstub --all`  

* require `rails_helper` in `.rspec` file  

### BDD test with Feature spec  
* feature test workflow setup  
~> create a file in `spec/features/home_page_spec.rb`  
~> `feature` is the same as `describe`  
~> `scenario` is the same as `it`  
~> Check Capybara built-in methods in notes cheat_sheets  
```ruby
feature 'home page' do
  scenario 'welcome message' do
    visit('/')
    expect(page).to have_content('Welcome')
  end
end
```

~> run test will get `routing error`  
```ruby
# route.rb
root to: 'welcome#index'
```

~> run test will get `controller error`  
```ruby
# welcome_controller.rb
class WelcomeController < ApplicationController
  class index
  end
end
```

~> run test will get `missing template`, create in `app/views/welcome/index.html.haml`  
~> run test will get `expected to find content ...`  

~> implment content in view  

### First Feature spec: Happy Path  
