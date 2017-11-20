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
  * [Shared examples](#shared-examples)  
  * [Testing authenticaion](#testing-authentication)  
  * [Testing authorization](#testing-authorization)  
* [Model tests](#model-test)  
  * [validation](#validation)  
  * [Shoulda matcher](#shoulda-matcher)  
  * [Test instance method](#test instance method)  
  * [Test DB Queries][#test-db-queries]  
* [Test in isolation](#test-in-isolation)  
  * [Test controller in isolation](#test-controller-in-isolation)  
* [other tests](#other-tests)  
  * [testing email](#testing-email)  
    * [implement mailer in feature spec][#implement-mailer-in-feature-spec]  
    * [create mailer and test](#create-mailer-and-test)  
  * [file upload and test](#file-upload-and-test)  
  * [Test third party api](test-third-party-api)  
  * [Test our own api](test-our-own-api)  
    * [Create spec and implement api](create-spec-and-implement-api)  
    * [create response JSON](create response JSON)  

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
  # Achievement.public_access == [Achievement_array of public_access_objects in db]
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

### Shared examples
* when test is expected with the same results, refactor using `shared_examples`  
```ruby
shared_examples "public access to achievements" do
  # let ...
  # before ...
  it "redirects to sign in path" do
    get :edit, id: 1
    expect(response).to redirect_to(new_user_session_path)
  end

  # ...
end
```

* when use in test block define `it_behaves_like "shared_examples_name"`  
```ruby
describe "guest users" do
  it_behaves_like "public access to achievements"
end
```

* define action to yeild action variable in `shared_examples`

```ruby
shared_examples "public access to achievements" do
  it "redirects to sign in path" do
    action
    expect(response).to redirect_to(new_user_session_path)
  end
end
```

* use `let` inside `it_behaves_like` block to yield action
```ruby
it_behaves_like "public access to achievements" do
  let(:action) { get :index }
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
describe "#description_html" do
  it "converts markdown to html" do
    achievement = Achievement.new(description: "**Awesome** *test*")
    # use include to test string include html string 
    expect(achievement.description_html).to include("<strong>Awesome</strong>")
    expect(achievement.description_html).to include("<em>test</em>")    
  end
end

describe "#author" do
  it "returns author string" do
    user = FactoryGirl.create(:user, email: "123@email.com")
    achievement = FactoryGirl.build(:public_achievement, title: "test", user: user )

    expect(achievement.author).to eq("test 123@email.com")
  end
end
```

### Test DB Queries
* setup record in order, call method and expec the return  
```ruby
# rspec
describe "get_letter" do
  it "returns array of match letter" do
    user = FactoryGirl.create(:user)
    achievement1 = FactoryGirl.create(:public_achievement, title: "achievement X", user: user)
    achievement2 = FactoryGirl.create(:public_achievement, title: "achievement Y", user: user)

    expect(Achievement.get_letter("X")).to eq([achievement1])
  end
end
```

```ruby
# Achievement model
def self.get_letter(letter)
  # rails helper query "%#{letter}%" search for whole string
  # if "#{letter}%" search for first letter of the string

  where("title LIKE ?", "%#{letter}%")
end
```

```ruby
describe "get_letter" do
  it "returns array of match letter" do
    #...
  end

  it "sorts achievements by user emails" do
    a = FactoryGirl.create(:user, email: "a@email.com")
    b = FactoryGirl.create(:user, email: "b@email.com")      
    achievement1 = FactoryGirl.create(:public_achievement, title: "Read achievement", user: b)
    achievement2 = FactoryGirl.create(:public_achievement, title: "Rock achievement", user: a)

    expect(Achievement.get_letter("R")).to eq([achievement2, achievement1])
  end
end
```

```ruby
# Achievement model
def self.get_letter(letter)
  # query with association
  # .include(:model_association_method).order("table.param")
  # will query with model associated method and order by table params 
  where("title LIKE ?", "%#{letter}%").includes(:user).order("users.email")
end
```

## Test in isolation  
* use for testing dependencies(code that depends on other code) by replaced the object with fake object(test double) then query message and/or command message  

### query message(stub)
* get some data in return, if not specified return nil  

* work flow: arrange(build obj), act(method or return), assert(expect)   
```ruby
# stub dependency and return predefined value
fake = Double(:fake) # replace with fake obj
allow(fake).to receive(:method) { return_value } # stub method and return predefined value
```

```ruby
# rspec double with defined class and stub method return
let(:double) { double("ClassName", some_method: nil) }
# instance double
let(:double) { instance_double(ClassName, some_method: nil) }

```

### command message(mock)
* tell object to do something(side effect), then act to see if message is passed

* work flow: arrange, assert(expect) then act  

> mock the expectation needs to come before action  

```ruby
# mock
# ensure that message(method) has been sent  
# replace obj with test double
# expect message sent to the object
expect(double).to receive(:message)
# mock always comes before action
get :index
```

### Test controller in isolation  
* revise `achievements_controller` test to test in isolation  

* test for `guest user` index action
```ruby
# controller
def index
  @achievements = Achievement.public_access
end

# rspec
describe AchievementsController do
  describe "guest user" do
    describe "GET index" do
      # define variable achievement to be double's instace of Achievement 
      let(:achievement) { instance_double(Achievement) }
      
      before do
        # send message to Achievement to receive method "public_access" and return array [ achievement ]
        allow(Achievement).to receive(:public_access) { [ achievement ] }
      end

      it "renders index template" do
        get :index
        expect(response).to render_template(:index)
      end

      it "finds public achievements" do
        get :index

        # expect @achievements === [achievement]
        expect(assigns[:achievements]).to eq([achievement])
      end
    end
  end
end
```

* test for `"guest user"` show action
```ruby
# controller
def show
  @achievement = Achievement.find(params[:id])
end

# test
describe "GET show" do
  let(:achievement) { instance_double(Achievement) }
  
  before do
    allow(Achievement).to receive(:find) { achievement }
  end

  it "renders template show" do
    get :show, id: achievement
    expect(response).to render_template(:show)
  end

  it "finds achievement" do
    get :show, id: achievement
    expect(assigns[:achievement]).to eq achievement
  end
end
```

* wrap show and index test in `shared_examples "public access to achievements"`  
```ruby
shared_examples "public access to achievements" do
  describe "GET index" do
    let(:achievement) { instance_double(Achievement) }
    
    before do
      allow(Achievement).to receive(:public_access) { [ achievement ] }
    end

    it "renders index template" do
      get :index
      expect(response).to render_template(:index)
    end

    it "finds public achievements" do
      get :index
      expect(assigns[:achievements]).to eq([achievement])
    end
  end

  describe "GET show" do
    let(:achievement) { instance_double(Achievement) }
    
    before do
      allow(Achievement).to receive(:find) { achievement }
    end

    it "renders template show" do
      get :show, id: achievement
      expect(response).to render_template(:show)
    end

    it "finds achievement" do
      get :show, id: achievement
      expect(assigns[:achievement]).to eq achievement
    end
  end
end
```

* then reuse in `guest user`
```ruby
describe "guest user" do
  it_behaves_like "public access to achievements"
end
```

* create `shared_examples` for `unauthorized user` and use in guest user  
```ruby
# rspec AchievementsController

shared_examples "public access to achievements" do
  #...
end

shared_examples "unauthorized user" do
  it "redirects to sign in page" do
    action
    expect(response).to redirect_to(new_user_session_path)
  end
end

describe "guest user" do
  let(:achievement_params) { { title: "title" } }

  it_behaves_like "public access to achievements"

  it_behaves_like "unauthorized user" do
    let(:action) { get :new }
  end

  it_behaves_like "unauthorized user" do
    let(:action) { post :create, achievement: achievement_params }
  end

  it_behaves_like "unauthorized user" do
    let(:action) { get :edit, id: 1 }
  end

  it_behaves_like "unauthorized user" do
    let(:action) { put :update, id: 1, achievement: achievement_params }
  end

  it_behaves_like "unauthorized user" do
    let(:action) { delete :destroy, id: 1 }
  end
end
``` 

* re-implement rspec for `auth user` create action, test for `"instantiated new achievement"` 
```ruby
# controller
def create
  @achievement = Achievement.new(achievement_params.merge(user: current_user))
  
  ## uncomment and comment the rest of the code below render to specifically test the code above 
  # render nothing: true

  if @achievement.save
    redirect_to @achievement
  else
    render :new
  end
end
```
```ruby
# rspec
describe "authenticated user" do
  it_behaves_like "public access to achievements"

  # create instance double for user
  let(:user) { instance_double(User) }

  before do
    # stub devise authenticate_user! method for our controller and return true to successful sign in
    allow(controller).to receive(:authenticate_user!) { true }
    # stub devise current_user method and return our user double to user our user double as current_user
    allow(controller).to receive(:current_user) { user }
  end

  describe "POST create" do
    # create instance for params since Achievement.new(achievement_params.merge(user: current_user)) will return { title: "..", description: "...", user_id: ".." }
    # user which passed in params is our stubbed current_user
    let(:achievement_params) { {title: "some title", user: user} }

    it "instantiated new achievement" do
      # create instance double with message 'save'
      # when test runs need to test the whole block of code, message 'save' will be needed for 'if @achievement.save'
      achievement = instance_double(Achievement, save: true)

      # stub new method and return achievement double
      allow(Achievement).to receive(:new) { achievement }

      # test with command message for Achievement, new method with passed parameters
      expect(Achievement).to receive(:new).with(achievement_params)

      # then post to controller with our test params to ensure the command message is received
      post :create, achievement: achievement_params
    end
  end
end
```

* test create action with invalid input and valid input
```ruby
# controller
def create
  @achievement = Achievement.new(achievement_params, current_user)

  if @achievement.save
    redirect_to @achievement
  else
    render :new
  end
end
```
```ruby
# test
describe "authenticated user" do
  # stub for devise..
  let(:user) { instance_double(User) }
    
  before do
    allow(controller).to receive(:authenticate_user!) { true }
    allow(controller).to receive(:current_user) { user }
  end

  describe "POST create" do
    # params always need user for auth user
    let(:achievement_params) { {title: "some title", user: user} }

    context "invalid input" do
      # for invalid input @achievement.save will be false
      # create achievement double with save method to return false
      let(:achievement) { instance_double(Achievement, save: false) }

      # then stubbed Achievement.new to return our double
      before do
        allow(Achievement).to receive(:new) { achievement }
      end

      it "render new template" do
        post :create, achievement: achievement_params

        # our double save will return false
        expect(response).to render_template :new
      end

      it "assigns achievement to the template" do
        post :create, achievement: achievement_params

        # @achivement will eq achievement double since we stubbed out Achievement.new and return the double
        expect(assigns[:achievement]).to eq achievement          
      end

      context "valid input" do
        # define achievement double, alternatively, can define save message here as well.
        let(:achievement) { instance_double(Achievement) }
      
        before do
          # stub Achievement.new then return our double
          allow(Achievement).to receive(:new) { achievement }

          # stub save method with our double and return true
          allow(achievement).to receive(:save) { true }
        end

        it "redirects to achievement page" do
          post :create, achievement: achievement_params

          # achievement.save == true
          expect(response).to redirect_to achievement_path achievement
        end
      end
    end
  end
end
```

* implement user signed in but `user is not the owner`  
```ruby
before_action :owners_only, only: [:edit, :update, :destroy]

# if user is not the owner will redirect
def owners_only
  @achievement = Achievement.find(params[:id])
  
  if current_user != @achievement.user
    redirect_to achievements_path
  end
end
```

```ruby
describe "authenticated user" do
  # stub for devise..
  let(:user) { instance_double(User) }
    
  before do
    allow(controller).to receive(:authenticate_user!) { true }
    allow(controller).to receive(:current_user) { user }
  end

  #...

  context "user is not the owner" do
    # create instance achievement_user double for User 
    let(:achievement_user) { instance_double(User) }

    # create achievement double then assigns achievement_user double as a return for user method.
    let(:achievement) { instance_double(Achievement, user: achievement_user) }
    
    before do
      # stub method find and return our double
      allow(Achievement).to receive(:find) { achievement }
    end

    # then when action occur at `if current_user != @achievement.user`, our current_user double; user will not equal with @achievement.user which already stubbed out with achievement.user
    describe "GET edit" do
      it "redirect to achievements page" do
        get :edit, id: achievement

        expect(response.status).to redirect_to achievements_path
      end
    end

    describe "PUT update" do
      it "redirect to achievements page" do
        put :update, id: achievement

        expect(response.status).to redirect_to achievements_path
      end
    end

    describe "DELETE destroy" do
      it "redirect to achievements page" do
        delete :destroy, id: achievement

        expect(response).to redirect_to achievements_path
      end
    end
  end
end
```

* implement user signed in and `user is the owner` 
```ruby
# controller
before_action :owners_only, only: [:edit, :update, :destroy]

#...

def edit
end

def update
  if @achievement.update(achievement_params)
    redirect_to achievement_path(@achievement)
  else
    render :edit
  end
end

def destroy
  if @achievement.destroy
    redirect_to achievements_path
  end
end

private
def owners_only
  @achievement = Achievement.find(params[:id])
  
  if current_user != @achievement.user
    redirect_to achievements_path
  end
end
```

```ruby
# test
describe "authenticated user" do
  # stub for devise..
  let(:user) { instance_double(User) }
    
  before do
    allow(controller).to receive(:authenticate_user!) { true }
    allow(controller).to receive(:current_user) { user }
  end

  context "user is the owner" do
    # to pass owners_only method current_user(stubbed with our user double) needs to be equal with achievement.user
    # so we create double achievement with user method to return user(stubbed for current_user)
    let(:achievement) { instance_double(Achievement, user: user) }

    before do
      # then we stubbed Achievement find method to return achievement double(with user method which will return user double that equal to current_user)
      # then we will get to test for owners
      allow(Achievement).to receive(:find) { achievement }
      get :edit, id: achievement
    end

    describe "GET edit" do
      before do
        # get edit with id from achievement
        # id can be any integer since we stubbed out the find method and predefined the return
        get :edit, id: achievement
      end
      
      it "renders edit template" do
        expect(response).to render_template :edit
      end
      
      it "sets achievement for edit template" do
        # stubbed out Achievement.find
        # so @achievement == achievement double
        expect(assigns[:achievement]).to eq achievement 
      end
    end

    describe "PUT update" do
      context "valid input" do
        # no need for user in update params since the user needs to be the same user to reach update action
        let(:achievement_params) { {title: "new title"} }

        before do
          # our achievement double from outer scope(stubbed with Achievement.find)
          # will stubbed the update method with params and return true
          allow(achievement).to receive(:update).with(achievement_params) { true }
          put :update, id: achievement, achievement: achievement_params
        end

        # @achievement.update is true
        # @achievement = achievement double
        it "redirect to achievement page" do
          expect(response).to redirect_to achievement_path(achievement)
        end
      end

      context "invalid input" do
        let(:achievement_params) { {title: ""} }

        before do
          # stub achievement then return false when recieve message update
          allow(achievement).to receive(:update).with(achievement_params) { false }
          put :update, id: achievement, achievement: achievement_params
        end

        it "render edit template" do
          expect(response).to render_template :edit
        end

        it "assigns achievement for edit template" do
          expect(assigns[:achievement]).to eq achievement
        end
      end
    end

    describe "DELETE destroy" do
      before do
        # our achievement double from outer scope
        # assign with destroy message and return true
        allow(achievement).to receive(:destroy) { true }
      end

      it "redirects to achievements page" do
        delete :destroy, id: achievement
        expect(response).to redirect_to achievements_path
      end
    end
  end
end
```

## other tests  
### testing email
* rails testing environment will set to test, and can be access with `ActionMailer::Base.deliveries`  
```ruby
# config/environments/test.rb
config.action_mailer.delivery_method = :test
# access array with ActionMailer::Base.deliveries
```

#### Implement mailer in feature spec
* implement feature spec to test for mailer  
```ruby
# create_achievement_spec
feature 'create new achievement' do
  # ...

  scenario 'create new achievement with valid data' do
    new_achievement_form.visit_page.fill_in_with.submit

    expect(ActionMailer::Base.deliveries.count).to eq 1
    expect(ActionMailer::Base.deliveries.last.to).to include(user.email)    
    # ...
  end
end
```

#### create mailer and test  
* create mailer, controller, view and test with `rails g mailer ModelMailer`  
`rails g mailer UserMailer`  

* define test for mailer  
```ruby
RSpec.describe UserMailer, type: :mailer do
  it 'sends email when achievement is created to owner' do
    # create ApplicationMailer email object
    # .achievement_created is our custom action
    # .deliver_now is rails method to deliver email
    email = UserMailer.achievement_created('user@email.com').deliver_now

    # .to is the method returns array of emails to mail to 
    expect(email.to).to include('user@email.com')
  end
end
```

* implement `UserMailer` to pass the test  
```ruby
# user_mailer.rb
class UserMailer < ApplicationMailer
  def achievement_created(email)
    # Mailer method to sent email
    mail to: email
  end
end
```

* implement view in `views/model_mailer/action`   
```ruby
# views/user_mailer/achievement_created.html.haml  
# some haml
```

* with working test, implement all the desired tests  
```ruby
require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  # include to ensure that rails url helper is working
  include Rails.application.routes.url_helpers

  # define achievement id for achievement_created
  let(:achievement_id) { 1 }
  let(:email) { UserMailer.achievement_created('user@email.com', achievement_id) }
  
  it 'sends email when achievement is created to owner' do
    email.deliver_now
    expect(email.to).to include('user@email.com')
  end

  it "has email subject" do
    expect(email.subject).to eq("Achievement created!")
  end

  it "has link to achievement from email body" do
    expect(email.body).to include(achievement_url(achievement_id))
  end
end
```

```ruby
# user_mailer.rb
class UserMailer < ApplicationMailer
  def achievement_created(email, achievement_id)
    # send id to view for email to link to show url
    @achievement_id = achievement_id
    mail(to: email, subject: "Achievement created!")
  end
end
```

```haml
-# use achievement_url to get to the url itself
-# helper achievement_path will go to show path which relative to app path, achievement_url will get to the url itself
= link_to "your achievement", achievement_url(@achievement_id)
```

* the test still fails since we need to implement controller to send email 

> Ideally sending email should be augmented with background processing jobs; eg: sidekiq

```ruby
def create
  @achievement = Achievement.new(achievement_params.merge(user: current_user))

  if @achievement.save
    # send email if successfully save
    UserMailer.achievement_created(current_user.email, @achievement.id).deliver_now
    redirect_to achievement_path(@achievement), notice: "Achievement has been created" 
  else
    render :new
  end
end
```

* fix controller test by stubbing `Mailer` to make test pass
```ruby
describe "authenticated user" do
  # other code...
  # stub email for auth user
  let(:user) { instance_double(User, email: "test@email.com") }

  describe "POST create" do
    # ...
    it "instantiated new achievement" do
      # stub id for acheivement double
      achievement = instance_double(Achievement, id: 1, save: true)
    end

    context "valid input" do
      let(:achievement) { instance_double(Achievement, id: 1) }

      before do
        #...
        # stub UserMailer with chain message
        allow(UserMailer).to receive_message_chain(:achievement_created, :deliver_now)
      end

      # clear email in Mailer array after tests 
      after(:each) do
        ActionMailer::Base.deliveries.clear
      end

      # tests ...
    end
  end
end
```

* optionally use `gem letter_opener` to preview mail in browser, `gem email-spec` for `ActionMailer` test matchers

### File upload and test
* implement file uploader in feature spec and `NewAchievementForm` to take image uploader as param  
```ruby
# create_achievement_spec.rb
scenario 'create new achievement with valid data' do
  new_achievement_form.visit_page.fill_in_with(
    title: "Read a book", 
    cover_image: "placeholder.jpg"
  ).submit
  #...
end
```

```ruby
# spec/support/features/new_achievement_form.rb
# class NewAchievementForm
def fill_in_with(params={title: "Read a book", cover_image: "placeholder.jpg"})
  #...
  
  attach_file('Cover image', Rails.root + "spec/fixtures/#{params[:cover_image]}")
  self
end
```

* test using `carrierwave` identifier method
```ruby
scenario 'create new achievement with valid data' do
  #...

  # .cover_image_identifier is a carrierwave gem method that returns file name
  expect(Achievement.last.cover_image_identifier).to eq('placeholder.jpg')
end
```

* install `gem 'carrierwave'`

* generate image uploader `rails g uploader CoverImage`, which will create class `CoverImageUploader` in `uploader` folder  

* mount uploader to specify model  
```ruby
# Achievement model
class Achievement < ActiveRecord::Base
  # mount_uploader :field, UploaderClass
  mount_uploader :cover_image, CoverImageUploader
  #...
end
```

* create test to upload only certain file type  
```ruby
# spec/uploaders/cover_image_uploader_spec.rb
describe CoverImageUploader do
  it 'allows only images' do
    # create uploader using CoverImageUploader.new(instance, field) 
    uploader = CoverImageUploader.new(Achievement.new, :cover_image)

    # expect a block to raise error
    expect do
      # open file and use carrierwave uploader to store a file
      File.open("#{Rails.root}/spec/fixtures/test.md") do |f|
        uploader.store!(f)
      end
    end.to raise_exception(CarrierWave::IntegrityError)
end
```

* upload `test.md` in `spec/fixtures`

* modify `cover_image_uploader.rb`
```ruby
# uncomment
def extension_whitelist
  %w(jpg jpeg gif png)
end
```

* test for file size, dimenison, etc the same way

### Test third party api
* Best approch is to test with integration test then cach api response with `gem vcr` 

* Mock browser response with `gem webmock` which needed to work with `gem vcr`   

#### example: test with twitter api  
* implement test in feature test  
```ruby
# create_achievement_spec.rb
scenario 'create new achievement with valid data' do
  #...
  expect(page).to have_content("Tweeted achievement! at https://twitter.com")
end
```

* create twitter app, get token from consumer key and aceess token from twitter at `apps.twitter.com`

* in `AchievementsController` implement `TwitterService` in create action if successfully created  
```ruby
def create
  @achievement = Achievement.new(achievement_params.merge(user: current_user))

  if @achievement.save
    UserMailer.achievement_created(current_user.email, @achievement.id).deliver_now

    # create twitter service
    tweet = TwitterService.new.tweet(@achievement.title)
    redirect_to achievement_path(@achievement), notice: "Achievement has been created. Tweeted achievement! at #{tweet.url}" 
  else
    render :new
  end
end
```

* install `gem twitter`

* create twitter service class in `app/services/twitter_service.rb`  
```ruby
class TwitterService
  def initialize
    # from twitter api doc
    @client = Twitter::REST::Client.new do |config|
      # ideally, use figaro to store credentials
      config.consumer_key = "..."
      config.consumer_secret = "..."
      config.access_token = "..."
      config.access_token_secret = "..."      
    end
  end

  def tweet(message)
    # update is method from twitter api
    @client.update(message)
  end
end
```

* Twitter will post tweets each time the test is run, capture response then cache with `gem vcr`, and mock the web behavior with `gem webmock`
```ruby
group :test do
  #...
  gem 'vcr'
  gem 'webmock'
end
```

* config in rails helper
```ruby
# ...
require 'vcr'

VCR.configure do |c|
  # store requests/response
  c.cassette_library_dir = 'spec/cassettes'
  # hook with webmock
  c.hook_into :webmock
  # vcr helper for adding to example
  c.configure_rspec_metadata!
end
```

* add vcr to example by specified `:vcr`, when run, the first time it will request and cache resquest/response in cassette then use that for following API request/response tests
```ruby
scenario 'create new achievement with valid data', :vcr do
  # ...

  expect(page).to have_content("Tweeted achievement! at https://twitter.com")
end
```

* stubbed `TwitterService` class in controller, will test in isolation  
```ruby
describe "POST create" do
  #...
  context "valid input", :vcr do
    let(:achievement) { instance_double(Achievement, id: 1) }
    # define tweet double
    let(:tweet) { instance_double(TwitterService) }

    before do
      allow(Achievement).to receive(:new) { achievement }
      allow(achievement).to receive(:save) { true }
      allow(UserMailer).to receive_message_chain(:achievement_created, :deliver_now)
      # need achievement title for tweet method, stubbed out and return with some string
      allow(achievement).to receive(:title) { "some title" }
      # stubbed tweet with our double
      allow(tweet).to receive(:tweet)
    end
  end
end
```

* create test for `twiiter_service.rb`
```ruby
describe TwitterService do
  describe "#tweet" do
    it "update message", :vcr do
      tweet = TwitterService.new.tweet("message")
      expect(tweet.id).not_to be_nil
    end
  end
end
```

### Test our own api  
* Test our json api; Setup, API request with custom header then test json response  

* generally test respose with return status and return  

* use rails request spec to test json API  

#### create spec and implement api 
* create `spec/requests/api/achievements_spec.rb`
```ruby
describe "Achievements API" do
  it "sends public achievements" do
    # rails request method
    # get 'url', data, header
    get '/api/achievements'
  end
end
```

* implement routes  
```ruby
# routes
# ...
# group routes under specific names
# controller will be under folder api/... namespace
namespace :api do
  # /api/...
  resources :achievements, only: [:index]
end
```

* implement controller  
```ruby
# app/controllers/api/achievements_controller.rb
class Api::AchievementsController < ApiController
  def index
    render nothing: true
  end
end
```

* create parent class `ApiController` and inherit from `ActionController::Base`
```ruby
# controllers/api_controller.rb
# create parent class for api namespace Controller 
class ApiController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
end
``` 

* implement more test for Achievements Api
```ruby
# spec/requests/api/achievements_spec.rb
describe "Achievements API" do
  it "sends public achievements" do
    public_achievement = FactoryGirl.create(:public_achievement, title: "JSON api")
    private_achievement = FactoryGirl.create(:private_achievement)
    
    get '/api/achievements'

    expect(response.status).to eq(200)
    # build json object from response body
    json = JSON.parse(response.body)

    expect(json['data'].count).to eq 1
    expect(json['data'][0]['type']).to eq "achievements"    
    expect(json['data'][0]['attributes']['title']).to eq "JSON api"        
  end
end
```

#### create response JSON
* implement in controller to return json when response back with `gem 'active_model_serializers'`   

* config `config/initializers/active_model_serializers.rb`
```ruby
ActiveModel::Serializer.config.adapter = ActiveModel::Serializer::Adapter::JsonApi
```

* run `rails g serializer Model`; `rails g serializer Achievement`  

* modify our serializer to return as specified  
```ruby
# app/serializers/achievement_serializer.rb
class AchievementSerializer < ActiveModel::Serializer
  attributes :id, :title
end
```

* implement the controller to return json as response  
```ruby
# api/achievements_controller.rb
class Api::AchievementsController < ApiController
  def index
    # return only public achievement
    achievements = Achievement.public_access

    render json: achievements
  end
end
```