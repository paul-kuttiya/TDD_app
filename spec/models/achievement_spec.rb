describe Achievement do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:title).scoped_to(:user_id).with_message("You already have the same title") }
    it { should validate_presence_of(:user) }
    it { should belong_to(:user) }
  end

  describe "#description_html" do
    it "converts markdown to html" do
      achievement = Achievement.new(description: "**Awesome** *test*")
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

  describe "get_letter" do
    it "returns array of match letter" do
      user = FactoryGirl.create(:user)
      achievement1 = FactoryGirl.create(:public_achievement, title: "achievement X", user: user)
      achievement2 = FactoryGirl.create(:public_achievement, title: "achievement Y", user: user)

      expect(Achievement.get_letter("X")).to eq([achievement1])
    end

    it "sorts achievements by user emails" do
      a = FactoryGirl.create(:user, email: "a@email.com")
      b = FactoryGirl.create(:user, email: "b@email.com")      
      achievement1 = FactoryGirl.create(:public_achievement, title: "Read achievement", user: b)
      achievement2 = FactoryGirl.create(:public_achievement, title: "Rock achievement", user: a)

      expect(Achievement.get_letter("R")).to eq([achievement2, achievement1])
    end
  end
end