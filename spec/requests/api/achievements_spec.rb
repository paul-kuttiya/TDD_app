describe "Achievements API" do
  it "sends public achievements" do
    user = FactoryGirl.create(:user)
    public_achievement = FactoryGirl.create(:public_achievement, user: user, title: "JSON api")
    private_achievement = FactoryGirl.create(:private_achievement, user: user)
    
    get '/api/achievements'

    expect(response.status).to eq(200)
    
    json = JSON.parse(response.body)

    expect(json['data'].count).to eq 1
    expect(json['data'][0]['type']).to eq "achievements"    
    expect(json['data'][0]['attributes']['title']).to eq "JSON api"        
  end
end