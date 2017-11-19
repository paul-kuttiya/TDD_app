require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  include Rails.application.routes.url_helpers

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
