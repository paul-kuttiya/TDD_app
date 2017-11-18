feature 'achievement page' do
  let(:user) { FactoryGirl.create(:user) }
  
  scenario 'achievement public page' do
    achievement = FactoryGirl.create(:achievement, title: "Public achievement", user: user)

    visit("/achievements/#{achievement.id}")
    expect(page).to have_content('Public achievement')
  end

  scenario 'render markdown description' do
    achievement = FactoryGirl.create(:achievement, description: "That *was* hard", user: user)

    visit("/achievements/#{achievement.id}")
    expect(page).to have_css('em', text: "was")
  end
end