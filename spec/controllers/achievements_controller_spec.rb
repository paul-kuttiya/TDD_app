describe AchievementsController do
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

  describe "PUT update" do
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
end