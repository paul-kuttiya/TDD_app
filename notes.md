# TDD with Ruby on rails  

### Table of contents  
* [Project initialization](#project-initialization)
* [Acceptance Tests](#acceptance-tests)
  * [First Feature spec](#first-feature-spec)

## Project Initialization  
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

## Acceptance Tests  
* Use to emulate client's interface  
~> test from outside(interface) to inside(db)  

* feature test workflow setup  
~> create a file in `spec/features/home_page_spec.rb`  
~> run test with spring by `bin/rspec` or `rspec`   
~> `feature` is the same as `describe`  
~> `scenario` is the same as `it`  
~> Check Capybara built-in methods in notes cheat_sheets  
* Example: test home page  
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

### First Feature spec  
#### Happy path  
* create `spec/features/create_achievement_spec.rb`  
~> visit home page  
~> click on `New Acheivement`  
~> fill form text field label `title` with `Read a book`  
~> fill in text area label `Description` with `Excellent read`  
~> select `Public` box from label `Privacy`  
~> check `Featured achievement` checkbox  
~> attach_file `Cover image`  
~> click `Create Achievement` button  
~> expect to see `Achievement has been created` on page  
~> expect `Achievement` model last title to equal `Read a book`  
```ruby
feature 'create new achievement' do
  scenario 'create new achievement with valid data' do
    # visit('link')
    visit('/')

    # click_on('botton')
    click_on('New Achievement')

    # fill_in('form_label', with: "content")    
    fill_in('Title', with: 'Read a book')
    fill_in('Description', with: 'Excellent read')    

    # select('field', from "select_label")
    select('Public', from: 'Privacy')  

    # check('checkbox')  
    check('Featured achievement')

    # attach_file('name', from: "file_path")
    attach_file('Cover image', from: "#{Rails.root}/spec/fixtures/cover_image.png")

    click_on('Create Achievement')

    # expect(page).to have_content(`html_content`)
    expect(page).to have_content('Achievement has been created')

    # expect(something).to eq something
    expect(Acheivement.last.title).to eq 'Read a book'
  end
end
```

* Create functionality to satisfy the test  
~> create nav for view, then include link to `New Achievement`  
~> define `achievements` route  
```ruby
#route
resources :achievements, only: [:new, :create]
```
~> create `achievements` controller, and `new` action  
~> create `achievements new` view, and add form for `@achievement`    
~> create `@achievement` instance in controller's new action, `Achievement` model to match with test form  
~> install `gem 'simple_form'` then run command `rails g simple_form:install --bootstrap`  
 
