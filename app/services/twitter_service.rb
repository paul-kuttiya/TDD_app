class TwitterService
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = "fLreLhFULyPeOvJdupgFvvs5S"
      config.consumer_secret = "C4FXuJYKHqythAUo0CH53TYXdjiq8NMNTfVt2nfJQv0SY3NUSd"
      config.access_token = "915838411-wEZT7tIicMYZVa9g1krGxXOkRDwnocAmpTsVy6rl"
      config.access_token_secret = "tcywVULaO7rEHQOKz353dbgm6tFqQheTHVlDeGHTJ7Dc8"
    end
  end

  def tweet(message)
    @client.update(message)
  end
end