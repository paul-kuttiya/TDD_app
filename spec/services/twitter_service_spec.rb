describe TwitterService do
  describe "#tweet" do
    it "update message", :vcr do
      tweet = TwitterService.new.tweet("message")
      expect(tweet.id).not_to be_nil
    end
  end
end