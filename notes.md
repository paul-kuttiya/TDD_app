# TDD with Ruby on rails  

### Table of contents  
* [Project initialization](#project-initialization)
* [Acceptance Tests](#acceptance-tests)
  * [First Feature spec](#first-feature-spec)  
    * [Happy Path](#happy-path)  
    * [Sad Path](#sad-path)  
    * [Refactor feature tests](#refactor-feature-tests)  
    * [Factory girl](#factory-girl)  
    * [Show page feature spec](#show-page-feature-spec)  
    * [Cucumber](#cucumber)  
* [Controller tests](#controller-tests)  
  * [Test new and show](#test-new-and-show)  
  * [Test create](#test-create)  
  * [Test index and edit](#test-index-and-edit)   
  * [Test update and destroy](#test-update-and-destroy)    
   
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
  gem 'database_cleaner'
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
  * test from outside(interface) to inside(db)  

* feature test workflow setup  
  * create a file in `spec/features/home_page_spec.rb`  
  * run test with spring by `bin/rspec` or `rspec`   
  * `feature` is the same as `describe`  
  * `scenario` is the same as `it`  
  * Check Capybara built-in methods in notes cheat_sheets  

* Example: test home page  
```ruby
feature 'home page' do
  scenario 'welcome message' do
    visit('/')
    expect(page).to have_content('Welcome')
  end
end
```

* then run test will get `routing error`  
```ruby
# route.rb
root to: 'welcome#index'
```

* then run test will get `controller error`  
```ruby
# welcome_controller.rb
class WelcomeController < ApplicationController
  class index
  end
end
```

* then run test will get `missing template`, create in `app/views/welcome/index.html.haml`  

* then test will get `expected to find content ...`  

* after that implment content in view  

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

> enum will create a rails query by string but store in interger, will also create methods from query string to return associated array  

```ruby
class Achievement < ActiveRecord::Base
  # create model method privacies, which can query string in array and store number in db
  # Achievement.privacies == {"public_access"=>0, "private_access"=>1, "friends_access"=>2}
  # Achievement.public_access == [#array_of_public_access in db]
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
#### Factory girl
* generate fake model for seed/test, can be combine with `Faker`    
```ruby
# spec/factories/achievement.rb  
FactoryGirl.define do
  # define default values
  factory :achievement do
    # return sequence num for unique title
    # use Faker(optional) 
    sequence(:title) { |n| "Achievement #{n}" }
    description "description"
    privacy Achievement.privacies[:private_access]
    featured false
    cover_image "some_file.png"

    # sub factory, inherit from parent with the exception of defined value
    factory :public_achievement do
      privacy Achievement.privacies[:public_access]
    end
  end
end
```

* create multiple objects with factory girl  
```ruby
FactoryGirl.create_list(:achievement, 3)
```

#### Show page feature spec
* create feature spec `achievement_page_spec`  
```ruby
feature 'achievement page' do
  scenario 'achievement public page' do
    achievement = FactoryGirl.create(:achievement, title: 'Public achievement')

    visit("/achievements/#{achievement.id}")
    expect(page).to have_content('Public achievement')
  end
end
```

* implement route for show page

* implment show action and show view   
```ruby
def show
  @achievement = Achievement.find(params[:id])
end
```

* implement markdown in `achievements_controller`  
```ruby
def show
  #...
  @description = Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(@achievement.description)
end
``` 

* implement another scenario, use `redcarpet` for rendering markdown  

* detect working markdown by `.have_css('tag', text: "text")` instead of page content  
```ruby
feature 'achievement page' do
  #...

  scenario 'render markdown description' do
    achievement = FactoryGirl.create(:achievement, description: "That *was* hard")

    visit("/achievements/#{achievement.id}")
    expect(page).to have_css('em', text: "was")
  end
end
```

#### Cucumber  
* add essential gems  
```ruby
group :development, :test do
  gem 'spring-commands-cucumber'
end

group :test do
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
end
```

* run spring command `bundle exec spring binstub --all`  

* generate cucumber with `rails g cucumber:install`  

* create cumcumber spec `rails_root/features/achievement_page.feature`, then implement the feature  
```cucumber
Feature: Achievement_page

  In order to read others achievements
  As a guest user
  I want to see public achievement

  Scenario: guest user sees public achievement
    Given I am a guest user
    And there is a public achievement
    When I go to the achievement's page
    Then I must see achievement's content
```

* run `cucumber` and paste create cucumber steps in  `rails_root/features/step_definitions/achievements_steps.rb`, then paste the warning in the file  
```ruby
Given(/^I am a guest user$/) do
  pending # express the regexp above with the code you wish you had
end

Given(/^there is a public achievement$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I go to the achievement's page$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I must see achievement's content$/) do
  pending # express the regexp above with the code you wish you had
end
```

* implement in the steps  
```ruby
Given(/^I am a guest user$/) do
end

Given(/^there is a public achievement$/) do
  # use instance variable to share between steps
  @achievement = FactoryGirl.create(:public_achievement, title: "Public achievement")
end

When(/^I go to the achievement's page$/) do
  visit(achievement_path(@achievement.id))
end

Then(/^I must see achievement's content$/) do
  expect(page).to have_content("Public achievement")
end
```

## Controller Tests  
* controller use for handle user requests, handle model and create response  

* treat controller action as black box and expect result from it  

### Test new and show  
```ruby
describe AchievementsController do
  describe "GET new" do
    it "renders :new template" do
      get :new
      expect(response).to render_template(:new)
    end

    it "assigns new Achievement to @achievement" do
      get :new
      expect(assigns[:achievement]).to be_a_new(Achievement)
    end
  end

  describe "GET show" do
    let(:achievement) { FactoryGirl.create(:achievement) }

    it "renders :show template" do
      get :show, { id: achievement.id }
      expect(response).to render_template(:show)
    end

    it "assigns reqested achievement to @achievement" do
      get :show, { id: achievement.id }
      expect(assigns[:achievement]).to eq achievement
    end
  end
end
```

### test create  
```ruby
describe "POST create" do
  context "valid input" do
    let(:achievement) { FactoryGirl.attributes_for(:public_achievement) }

    before do
      post :create, achievement: achievement
    end
    
    it "redirects to achievement#show" do
      expect(response).to redirect_to(assigns[:achievement])
    end

    it "creates new achievement in database" do
      expect(Achievement.count).to eq 1
    end
  end

  context "invalid input" do
    let(:achievement) { FactoryGirl.attributes_for(:public_achievement, title: '') }
    
    before do
      post :create, achievement: achievement
    end

    it "renders new" do
      expect(response).to render_template :new
    end

    it "does not create new achievement in the database" do
      expect(Achievement.count).to eq 0
    end
  end
end
```

### Test index and edit  
* implement edit and index test then integrate in the controller  

* modify route to have edit and index for `achievements_controller` then create view `index` and `edit`  

```ruby
# rspec
describe "GET index" do
  it "renders :index template" do
    get :index
    expect(response).to render_template :index
  end
  
  it "assigns only public achievements to view" do
    public_achievement = FactoryGirl.create(:public_achievement)
    private_achievement = FactoryGirl.create(:private_achievement)
    
    get :index
    expect(assigns[:achievements]).to match_array([public_achievement])
  end
end

describe "GET edit" do
  let(:achievement) { FactoryGirl.create(:public_achievement) }

  before do
    get :edit, id: achievement
  end

  it "renders :edit template" do
    expect(response).to render_template :edit
  end
  
  it "assigns the achievement values to template" do
    expect(assigns[:achievement]).to eq achievement
  end
end
```

```ruby
# controller
def index
  @achievements = Achievement.public_access
end

def edit
  @achievement = Achievement.find(params[:id])
end
```

### Test update and destroy  
