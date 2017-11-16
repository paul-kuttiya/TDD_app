describe Achievement do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:title).scoped_to(:user_id).with_message("You already have the same title") }
    it { should validate_presence_of(:user) }
    it { should belong_to(:user) }
  end

  it "converts markdown to html" do
    achievement = Achievement.new(description: "**Awesome** *test*")
    expect(achievement.description_html).to include("<strong>Awesome</strong>")
    expect(achievement.description_html).to include("<em>test</em>")    
  end

  it "returns author string" do
    user = FactoryGirl.create(:user, email: "123@email.com")
    achievement = FactoryGirl.build(:public_achievement, title: "test", user: user )

    expect(achievement.author).to eq("test 123@email.com")
  end
end