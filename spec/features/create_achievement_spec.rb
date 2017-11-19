feature 'create new achievement' do
  let(:new_achievement_form) { NewAchievementForm.new }
  let(:login_form) { LoginForm.new }
  let(:user) { FactoryGirl.create(:user) }
  
  before do
    login_form.visit_page.login_as(user)
  end

  scenario 'create new achievement with valid data', :vcr do
    new_achievement_form.visit_page.fill_in_with(
      title: "Read a book", 
      cover_image: "placeholder.jpg"
    ).submit
    
    expect(ActionMailer::Base.deliveries.count).to eq 1
    expect(ActionMailer::Base.deliveries.last.to).to include(user.email) 

    expect(Achievement.last.cover_image_identifier).to eq('placeholder.jpg')
    expect(page).to have_content('Achievement has been created')
    expect(Achievement.last.title).to eq 'Read a book'
    expect(page).to have_content("Tweeted achievement! at https://twitter.com")
  end

  scenario 'cannot create achievement with invalid data' do
    new_achievement_form.visit_page.submit

    expect(page).to have_content('can\'t be blank')    
  end
end