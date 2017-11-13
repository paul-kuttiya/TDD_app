# TDD with Ruby on rails  

### Table of contents  
* [Project initialization](#project-initialization)
* [Acceptance Tests](#acceptance-tests)
  * [First Feature spec](#first-feature-spec)  
    * [Happy Path](#happy-path)  
    * [Sad Path](#sad-path)  
    * [Refactor feature tests](#refactor-feature-tests)
    

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

    # attach_file('name', "file_path")
    attach_file('Cover image', Rails.root + "spec/fixtures/placeholder.jpg")

    click_on('Create Achievement')

    # expect(page).to have_content(`html_content`)
    expect(page).to have_content('Achievement has been created')

    # expect(something).to eq something
    expect(Acheivement.last.title).to eq 'Read a book'
  end
end
```

##### Create functionality to satisfy the test
* create nav for view, then include link to `New Achievement`  

* define `achievements` route
  ```ruby
  #route
  resources :achievements, only: [:new, :create]
  ```

* create `achievements` controller, and `new` action  

* create `achievements new` view, and add form for `@achievement`    

* create `@achievement` instance in controller's new action, `Achievement` model to match with test form 

* install `gem 'simple_form'` then run command `rails g simple_form:install --bootstrap`  

* create inputs for form
```ruby
```
* create `privacies` method in `Achievement` model for select box  
```ruby
class Achievement < ActiveRecord::Base
  # create model method privacies, which can query string in array and store number in db
  # Achievement.privacies == {"public_access"=>0, "private_access"=>1, "friends_access"=>2}
  enum privacy: [:public_access, :private_access, :friends_access]
end
```

* assign file in the folder to test attach file at `./spec/fixtures/placeholder.png`  

* create submit button  

* create `create` action in `achievements_controller`  
```ruby
def create
  @achievement = Achievement.new(achievement_params)

  if @achievement.save
    redirect_to root_path, notice: "Achievement has been created"
  end
end

private

def achievement_params
  params.require(:achievement).permit!  
end
```

* create flash message in views and display before yeild  
```ruby
- if flash[:notice]
  .alert.alert-info= flash[:notice]
``` 

#### Sad path  
* implement fail scenario in `create_achievement_spec`   
```ruby
scenario 'cannot create achievement with invalid data' do
  visit('/')
  click_on('New Achievement')

  click_on('Create Achievement')
  expect(page).to have_content('can\'t be blank')    
end
```

##### Create functionality to satisfy the test
* implement validation in Achievement model, validates only one error to ensure feature test, the rest should be in model unit tests  
```ruby
validates :title, presence: true
```

* implement `achievements_controller`    
```ruby
def create
  @achievement = Achievement.new(achievement_params)

  if @achievement.save
    redirect_to root_path, notice: "Achievement has been created"
  else
    render :new
  end
end
```

#### Refactor feature tests  
* create `spec/support/new_achievement_form.rb`  
```ruby
class NewAchievementForm
  # include to use capybara helper
  include Capybara::DSL

  def visit_page
    visit('/')
    click_on('New Achievement')

    self # returns self to be able to chain method
  end

  def fill_in_with(params={title: "Read a book"})
    fill_in('Title', with: params[:title])
    fill_in('Description', with: 'Excellent read')    
    select('Public', from: 'Privacy')    
    check('Featured achievement')
    attach_file('Cover image', Rails.root + "spec/fixtures/placeholder.jpg")

    self
  end

  def submit
    click_on('Create Achievement')
  end
end
```

* require_relative in `create_achievement_spec`, and refactor the spec by create instance in let block the use the refactor method for test    
```ruby
require_relative '../support/new_achievement_form.rb'

feature 'create new achievement' do
  let(:new_achievement_form) { NewAchievementForm.new }
  
  scenario 'create new achievement with valid data' do
    new_achievement_form.visit_page.fill_in_with.submit

    expect(page).to have_content('Achievement has been created')
    expect(Achievement.last.title).to eq 'Read a book'
  end

  scenario 'cannot create achievement with invalid data' do
    new_achievement_form.visit_page.submit

    expect(page).to have_content('can\'t be blank')    
  end
end
```  