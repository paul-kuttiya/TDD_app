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
  * [Install devise](#install-devise)  
  * [Testing authenticaion](#testing-authentication)  
  * [Testing authorization](#testing-authorization)  
* [Model tests](#model-test)  
  * [validation](#validation)  
  * [Shoulda matcher](#shoulda-matcher)  
  * [Test instance method](#test instance method)  


> run `rspec` to test all, `rspec spec/path...` to test file, `rspec --format=documentation spec/path...` to test as documentation

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
  * visit home page  
  * click on `New Acheivement`  
  * fill form text field label `title` with `Read a book`  
  * fill in text area label `Description` with `Excellent read`  
  * select `Public` box from label `Privacy`  
  * check `Featured achievement` checkbox  
  * attach_file `Cover image`  
  * click `Create Achievement` button  
  * expect to see `Achievement has been created` on page  
  * expect `Achievement` model last title to equal `Read a book`  
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

### Create functionality to satisfy the test
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
= simple_form_for @achievement do |f|
  = f.input :title
  = f.input :description
  = f.input :privacy, collection: Achievement.privacies.map { |k, v| [k.split('_').first.capitalize, k] }
  = f.input :featured, label: 'Featured achievement'
  = f.input :cover_image, as: :file
  = f.submit "Create Achievement", class: "btn btn-danger"
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

> alternatively, without `require_relative` all the time, tell `rails_helper.rb` to load all files in `spec/support/**/*.rb` before the test run, move support files to `spec/support/features/file.rb` 

```ruby
# rails_helper
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
```

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
* implement test for update  
```ruby
describe "PUT update" do
  # FactoryGirl create object in database
  let(:achievement) { FactoryGirl.create(:public_achievement) }

  context "valid input" do
    let(:valid_achievement) { FactoryGirl.attributes_for(:public_achievement, title: "New title") }      

    before do
      put :update, id: achievement, achievement: valid_achievement
    end

    it "redirects to achievements#show" do
      expect(response).to redirect_to achievement
    end

    it "updates data in the database" do
      # reload instance from database after update
      achievement.reload
      expect(achievement.title).to eq "New title"
    end
  end

  # context for invalid input

end
```

* implement controller and view accordingly  
```ruby
def update
  @achievement = Achievement.find(params[:id])

  if @achievement.update(achievement_params)
    redirect_to @achievement
  end
end
```

* test for update invalid input  
```ruby
describe "PUT update" do
  let(:achievement) { FactoryGirl.create(:public_achievement) }

  # context valid input

  context "invalid input" do
    let(:invalid_achievement) { FactoryGirl.attributes_for(:public_achievement, title: "") }

    before do
      put :update, id: achievement, achievement: invalid_achievement
    end

    it "renders an edit template" do
      expect(response).to render_template :edit
    end

    it "does not update database" do
      achievement.reload
      expect(achievement).not_to be ""
    end
  end
end
```

* implement controller and view accordingly  
```ruby
def update
  @achievement = Achievement.find(params[:id])

  if @achievement.update(achievement_params)
    redirect_to @achievement
  else
    render :edit
  end
end
```

* test for destroy  
```ruby
describe "DELETE destroy" do
  let(:achievement) { FactoryGirl.create(:public_achievement) }
  
  before do
    delete :destroy, id: achievement
    expect(Achievement.count).to eq 0
  end

  it "redirects to achievement#index" do
    expect(response).to redirect_to achievements_path
  end

  it "destroys achievement from database" do
    expect(Achievement.exists?(achievement.id)).to be false
  end
end
```

* implement action  
```ruby
def destroy
  if Achievement.destroy(params[:id])
    redirect_to achievements_path
  end
end
```

### Install devise
* include gemfile `gem devise`  

* run `rails g devise:install`  

* config mailer in `environments/developement.rb`, `test.rb` and `production.rb`   
```ruby
# development, and test
# In production, :host should be set to the actual host of your application.
config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
```

* generate user with devise `rails g devise model_name`; eg: `rails g devise user`, then run `rake db:migrate`  

* create default values for `user` FactoryGirl  
```ruby
FactoryGirl.define do
  factory :user do
    # increment for every Factory instance
    sequence(:email) { |n| "email#{n}@email.com" }
    password "secretpassword"
  end
end
```

* Devise provide method for testing controller, config in `rails_helper.rb`
```ruby
#...
require 'rspec/rails'
require 'devise'

RSpec.configure do |config|
  #...
  config.include Devise::TestHelpers, type: :controller
end
```

### Testing authenticaion  
* Guest has access for index and show 

* user has access for index, show, new and create

* owner has access for index, show, edit, update, destroy  

### test for `guest user`  
* move get `index` and `show` spec in `guest user` test scope  

* add test for request to unpermited action  
```ruby
describe "guest user" do
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

  describe "GET new" do
    it "redirects to user#new page" do
      get :new
      expect(response).to redirect_to new_user_session_path
    end
  end

  describe "POST create" do
    it "redirects to user#new page" do
      post :create, achievement: FactoryGirl.attributes_for(:public_achievement)
      expect(response).to redirect_to new_user_session_path
    end
  end

  describe "GET edit" do
    it "redirects to user#new page" do
      post :create, id: FactoryGirl.create(:public_achievement)
      expect(response).to redirect_to new_user_session_path
    end
  end

  describe "PUT update" do
    it "redirects to user#new page" do
      post :update, id: FactoryGirl.create(:public_achievement), achievement: FactoryGirl.attributes_for(:public_achievement)
      expect(response).to redirect_to new_user_session_path
    end
  end

  describe "DELETE destroy" do
    it "redirects to user#new page" do
      delete :destroy, id: FactoryGirl.create(:public_achievement)
      expect(response).to redirect_to new_user_session_path
    end
  end
end
```

```ruby
class AchievementsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
end
```

* run test only for the new implemented blocked and will pass  

### Testing authorization  
* implement test for `authorized user` and `owner`; move from index, show, new, create test, use `FactoryGirl.create(:user)` and devise helper `sign_in(:user)` before for authorized user  

* add user is not the owner of achievement context  
```ruby
describe "authenticated user" do
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in(user)
  end
  
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

  context "user is not the owner of the achievement" do
    describe "GET edit" do
      it "redirects to achievements#index" do
        post :create, id: FactoryGirl.create(:public_achievement)
        expect(response).to redirect_to achievements_path
      end
    end

    describe "PUT update" do
      it "redirects to achievements#index" do
        post :update, id: FactoryGirl.create(:public_achievement), achievement: FactoryGirl.attributes_for(:public_achievement)
        expect(response).to redirect_to achievements_path
      end
    end

    describe "DELETE destroy" do
      it "redirects to achievements#index" do
        delete :destroy, id: FactoryGirl.create(:public_achievement)
        expect(response).to redirect_to achievements_path
      end
    end
  end

  context "user is the owner of the achievement" do
    #...
  end
end
```

* to satisfy the test, create association for `User` and `Achievement` model, create migration with ```rails g migration AddUserToAchievements user:references```; will add `user_id` as a reference to `achievements` table    

* run `rake db:migrate`

* for 1:M relationship; add `belongs_to :user` in `Achievement` model, and `has_many :achievements` in `User` model  

* implement `cancan`, `pundit` gem, or implement in controller manually  
```ruby
class AchievementsController < ApplicationController
  before_action :owners_only, only: [:edit, :update, :destroy]

  #...

  def owners_only
    @achievement = Achievement.find(params[:id])

    # current_user is a devise method
    if current_user != @achievement.user
      redirect_to achievements_path
    end
  end
end
```

> `owners_only` will run before `edit, update, destroy` action, refactor the code  

* implement `user is the owner of achievement context`, by moving the `edit, update, destroy` test to the context    
```ruby
describe "authenticated user" do
  let(:user) { FactoryGirl.create(:user) }

  before do
    sign_in(user)
  end

  context "user is not the owner of the achievement" do
    #...
  end

  # predefined achievement associated with user
  context "user is the owner of the achievement" do
    # user variable from outer scope
    let(:achievement) { FactoryGirl.create(:public_achievement, user: user) }

    describe "GET edit" do
      # remove achievement and user from outer scope
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

    describe "PUT update" do
      context "valid input" do
        let(:valid_achievement) { FactoryGirl.attributes_for(:public_achievement, title: "New title") }      

        before do
          put :update, id: achievement, achievement: valid_achievement
        end

        it "redirects to achievements#show" do
          expect(response).to redirect_to achievement
        end

        it "updates data in the database" do
          achievement.reload
          expect(achievement.title).to eq "New title"
        end
      end

      context "invalid input" do
        let(:invalid_achievement) { FactoryGirl.attributes_for(:public_achievement, title: "") }

        before do
          put :update, id: achievement, achievement: invalid_achievement
        end

        it "renders an edit template" do
          expect(response).to render_template :edit
        end

        it "does not update database" do
          achievement.reload
          expect(achievement).not_to be ""
        end
      end
    end

    describe "DELETE destroy" do
      before do
        delete :destroy, id: achievement
        expect(Achievement.count).to eq 0
      end

      it "redirects to achievement#index" do
        expect(response).to redirect_to achievements_path
      end

      it "destroys achievement from database" do
        expect(Achievement.exists?(achievement.id)).to be false
      end
    end
  end
end
```

* remove duplication and move to shared_examples  
```ruby
describe AchievementsController do
  shared_examples "public access to achievements" do
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

    describe "GET new" do
      it "redirects to user#new page" do
        get :new
        expect(response).to redirect_to new_user_session_path
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
end
```

* call `shared_examples` with `it_behaves_like "method"`, alternatively, move shared_examples to `spec/support/shared_examples.rb`
```ruby
describe "guest user" do
  it_behaves_like "public access to achievements"
  #...
end
```

* run whole spec will fail since feature test is not logged in user  

* implement log_in in feature spec `create_achievement_spec.rb`, by create new class in `spec/support/features/login_form.rb` and use in spec  
```ruby
# spec/support/features/login_form.rb
class LoginForm
  # include to user Capybara methods
  include Capybara::DSL

  def visit_page
    # default page view already provided with devise gem
    # check routes in rake routes
    visit("/users/sign_in")
    self
  end

  def login_as(user)
    # default devise gem signin view with input "Email", "Password" and "Log in"
    fill_in("Email", with: user.email)
    fill_in("Password", with: user.password)
    click_on("Log in")
    self
  end
end
```

```ruby
feature 'create new achievement' do
  #...
  let(:login_form) { LoginForm.new }
  let(:user) { FactoryGirl.create(:user) }

  before do
    login_form.visit_page.login_as(user)
  end

  # scenario "..."  
  # ...
end
```

## Model tests  
* ActiveRecord model is mostly responsibled for validation, association, db query and business logic  

### validation  
* validate `Achievement` model  

* to create custom validation with custom method  
```ruby
validate :custom_validation

def custom_validation
  existing = self.class.find_by(title: title)
  if existing && existing.user == user
    # custom error
    errors.add(:title, "title can't be the same")
  end 
end
```

* custom uniqueness validation  with rails helper  
```ruby
class Achievement < ActiveRecord::Base
  ## unique title for the whole database
  # validates :title, uniqueness: true

  validates :title, uniqueness: {
    # title unique for one title per user_id
    scope: :user_id,
    message: "You already have the same title" 
  }
end  
```

### Shoulda matcher  
* use for testing rails model methods and association  

* include gemfile `gem shoulda-matchers, require: false` in test group and run bundle install  

* require in `rails_helper`
```ruby
require 'rspec/rails'
require 'shoulda/matchers'
#...
```

* test for model association, validation and so on, refer to `shoulda-matchers` spec  
```ruby
describe Achievement do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:title).scoped_to(:user_id).with_message("You already have the same title") }
    it { should validate_presence_of(:user) }
    it { should belong_to(:user) }
  end
end
```

```ruby
# Achievement Model
class Achievement < ActiveRecord::Base
  belongs_to :user
  
  validates :title, presence: true
  validates :user, presence: true
  validates :title, uniqueness: {
    scope: "user_id",
    message: "You already have the same title"
  }

  # ...
end
```

### test instance method  
* instance model with data, run method on the object and expect the value  

* DO NOT test api, use stub and mock for API, test only a return for instance method only  

```ruby
# model
class Achievement < ActiveRecord::Base
  def description_html
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(description).html_safe
  end

  def author
    "#{title} #{user.email}"
  end
end
```

```ruby
# rspec test
it "converts markdown to html" do
  achievement = Achievement.new(description: "**Awesome** *test*")
  # use include to test string include html string 
  expect(achievement.description_html).to include("<strong>Awesome</strong>")
  expect(achievement.description_html).to include("<em>test</em>")    
end

it "returns author string" do
  user = FactoryGirl.create(:user, email: "123@email.com")
  achievement = FactoryGirl.build(:public_achievement, title: "test", user: user )

  expect(achievement.author).to eq("test 123@email.com")
end

```