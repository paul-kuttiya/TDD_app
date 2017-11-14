feature 'achievement page' do
  scenario 'achievement public page' do
    achievement = FactoryGirl.create(:achievement, title: "Public achievement")

    visit("/achievements/#{achievement.id}")
    expect(page).to have_content('Public achievement')


  end

  scenario 'render markdown description' do
    achievement = FactoryGirl.create(:achievement, description: "That *was* hard")

    visit("/achievements/#{achievement.id}")
    expect(page).to have_css('em', text: "was")
  end
end