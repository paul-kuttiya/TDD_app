# describe AchievementsController do
#   shared_examples "public access to achievements" do
#     describe "GET index" do
#       it "renders :index template" do
#         get :index
#         expect(response).to render_template :index
#       end
      
#       it "assigns only public achievements to view" do
#         public_achievement = FactoryGirl.create(:public_achievement)
#         private_achievement = FactoryGirl.create(:private_achievement)
        
#         get :index
#         expect(assigns[:achievements]).to match_array([public_achievement])
#       end
#     end

#     describe "GET show" do
#       let(:achievement) { FactoryGirl.create(:achievement) }

#       it "renders :show template" do
#         get :show, { id: achievement.id }
#         expect(response).to render_template(:show)
#       end

#       it "assigns reqested achievement to @achievement" do
#         get :show, { id: achievement.id }
#         expect(assigns[:achievement]).to eq achievement
#       end
#     end
#   end
  
#   describe "guest user" do

#     it_behaves_like "public access to achievements"
    
#     describe "GET new" do
#       it "redirects to user#new page" do
#         get :new
#         expect(response).to redirect_to new_user_session_path
#       end
#     end

#     describe "POST create" do
#       it "redirects to user#new page" do
#         post :create, achievement: FactoryGirl.attributes_for(:public_achievement)
#         expect(response).to redirect_to new_user_session_path
#       end
#     end

#     describe "GET edit" do
#       it "redirects to user#new page" do
#         get :edit, id: FactoryGirl.create(:public_achievement)
#         expect(response).to redirect_to new_user_session_path
#       end
#     end

#     describe "PUT update" do
#       it "redirects to user#new page" do
#         post :update, id: FactoryGirl.create(:public_achievement), achievement: FactoryGirl.attributes_for(:public_achievement)
#         expect(response).to redirect_to new_user_session_path
#       end
#     end

#     describe "DELETE destroy" do
#       it "redirects to user#new page" do
#         delete :destroy, id: FactoryGirl.create(:public_achievement)
#         expect(response).to redirect_to new_user_session_path
#       end
#     end
#   end
  
#   describe "authenticated user" do
#     let(:user) { FactoryGirl.create(:user) }

#     before do
#       sign_in(user)
#     end
    
#     it_behaves_like "public access to achievements"

#     describe "GET new" do
#       it "renders :new template" do
#         get :new
#         expect(response).to render_template(:new)
#       end

#       it "assigns new Achievement to @achievement" do
#         get :new
#         expect(assigns[:achievement]).to be_a_new(Achievement)
#       end
#     end

#     describe "POST create" do
#       context "valid input" do
#         let(:achievement) { FactoryGirl.attributes_for(:public_achievement) }

#         before do
#           post :create, achievement: achievement
#         end
        
#         it "redirects to achievement#show" do
#           expect(response).to redirect_to(assigns[:achievement])
#         end

#         it "creates new achievement in database" do
#           expect(Achievement.count).to eq 1
#         end
#       end

#       context "invalid input" do
#         let(:achievement) { FactoryGirl.attributes_for(:public_achievement, title: '') }
        
#         before do
#           post :create, achievement: achievement
#         end

#         it "renders new" do
#           expect(response).to render_template :new
#         end

#         it "does not create new achievement in the database" do
#           expect(Achievement.count).to eq 0
#         end
#       end
#     end

#     context "user is not the owner of the achievement" do
#       describe "GET edit" do
#         it "redirects to achievements#index" do
#           get :edit, id: FactoryGirl.create(:public_achievement)
#           expect(response).to redirect_to achievements_path
#         end
#       end

#       describe "PUT update" do
#         it "redirects to achievements#index" do
#           post :update, id: FactoryGirl.create(:public_achievement), achievement: FactoryGirl.attributes_for(:public_achievement)
#           expect(response).to redirect_to achievements_path
#         end
#       end

#       describe "DELETE destroy" do
#         it "redirects to achievements#index" do
#           delete :destroy, id: FactoryGirl.create(:public_achievement)
#           expect(response).to redirect_to achievements_path
#         end
#       end
#     end

#     context "user is the owner of the achievement" do
#       let(:achievement) { FactoryGirl.create(:public_achievement, user: user) }

#       describe "GET edit" do
#         before do
#           get :edit, id: achievement
#         end

#         it "renders :edit template" do
#           expect(response).to render_template :edit
#         end
        
#         it "assigns the achievement values to template" do
#           expect(assigns[:achievement]).to eq achievement
#         end
#       end

#       describe "PUT update" do
#         context "valid input" do
#           let(:valid_achievement) { FactoryGirl.attributes_for(:public_achievement, title: "New title") }      

#           before do
#             put :update, id: achievement, achievement: valid_achievement
#           end

#           it "redirects to achievements#show" do
#             expect(response).to redirect_to achievement
#           end

#           it "updates data in the database" do
#             achievement.reload
#             expect(achievement.title).to eq "New title"
#           end
#         end

#         context "invalid input" do
#           let(:invalid_achievement) { FactoryGirl.attributes_for(:public_achievement, title: "") }

#           before do
#             put :update, id: achievement, achievement: invalid_achievement
#           end

#           it "renders an edit template" do
#             expect(response).to render_template :edit
#           end

#           it "does not update database" do
#             achievement.reload
#             expect(achievement).not_to be ""
#           end
#         end
#       end

#       describe "DELETE destroy" do
#         before do
#           delete :destroy, id: achievement
#           expect(Achievement.count).to eq 0
#         end

#         it "redirects to achievement#index" do
#           expect(response).to redirect_to achievements_path
#         end

#         it "destroys achievement from database" do
#           expect(Achievement.exists?(achievement.id)).to be false
#         end
#       end
#     end
#   end
# end

## test in isolation
describe AchievementsController do
  shared_examples "public access to achievements" do
    describe "GET index" do
      let(:achievement) { instance_double(Achievement) }
      
      before do
        allow(Achievement).to receive(:public_access) { [ achievement ] }
      end

      it "renders index template" do
        get :index
        expect(response).to render_template(:index)
      end

      it "finds public achievements" do
        get :index
        expect(assigns[:achievements]).to eq([achievement])
      end
    end

    describe "GET show" do
      let(:achievement) { instance_double(Achievement) }
      
      before do
        allow(Achievement).to receive(:find) { achievement }
      end

      it "renders template show" do
        get :show, id: achievement
        expect(response).to render_template(:show)
      end

      it "finds achievement" do
        get :show, id: achievement
        expect(assigns[:achievement]).to eq achievement
      end
    end    
  end

  shared_examples "unauthorized user" do
    it "redirects to sign in page" do
      action
      expect(response).to redirect_to(new_user_session_path)
    end
  end
  
  describe "guest user" do
    let(:achievement_params) { { title: "title" } }

    it_behaves_like "public access to achievements"

    it_behaves_like "unauthorized user" do
      let(:action) { get :new }
    end

    it_behaves_like "unauthorized user" do
      let(:action) { post :create, achievement: achievement_params }
    end

    it_behaves_like "unauthorized user" do
      let(:action) { get :edit, id: 1 }
    end

    it_behaves_like "unauthorized user" do
      let(:action) { put :update, id: 1, achievement: achievement_params }
    end

    it_behaves_like "unauthorized user" do
      let(:action) { delete :destroy, id: 1 }
    end
  end

  describe "authenticated user" do
    it_behaves_like "public access to achievements"
    
    let(:user) { instance_double(User) }
    
    before do
      allow(controller).to receive(:authenticate_user!) { true }
      allow(controller).to receive(:current_user) { user }
    end

    describe "POST create" do
      let(:achievement_params) { {title: "some title", user: user} }

      it "instantiated new achievement" do
        achievement = instance_double(Achievement, save: true)
        allow(Achievement).to receive(:new) { achievement }
        
        expect(Achievement).to receive(:new).with(achievement_params)
        post :create, achievement: achievement_params
      end

      context "invalid input" do
        let(:achievement) { instance_double(Achievement)}
      
        before do
          allow(Achievement).to receive(:new) { achievement }
          allow(achievement).to receive(:save) { false }
        end

        it "render new template" do
          post :create, achievement: achievement_params
          expect(response).to render_template :new
        end

        it "assigns achievement to the template" do
          post :create, achievement: achievement_params
          expect(assigns[:achievement]).to eq achievement          
        end
      end

      context "valid input" do
        let(:achievement) { instance_double(Achievement) }
      
        before do
          allow(Achievement).to receive(:new) { achievement }
          allow(achievement).to receive(:save) { true }
        end

        it "redirects to achievement page" do
          post :create, achievement: achievement_params
          expect(response).to redirect_to achievement_path achievement
        end
      end
    end

    context "user is not the owner" do
      let(:achievement_user) { instance_double(User) }
      let(:achievement) { instance_double(Achievement, user: achievement_user) }

      before do
        allow(Achievement).to receive(:find) { achievement }
      end

      describe "GET edit" do
        it "redirect to achievements page" do
          get :edit, id: achievement

          expect(response.status).to redirect_to achievements_path
        end
      end

      describe "PUT update" do
        it "redirect to achievements page" do
          put :update, id: achievement

          expect(response.status).to redirect_to achievements_path
        end
      end

      describe "DELETE destroy" do
        it "redirect to achievements page" do
          delete :destroy, id: achievement

          expect(response).to redirect_to achievements_path
        end
      end
    end

    context "user is the owner" do
      let(:achievement) { instance_double(Achievement, user: user) }

      before do
        allow(Achievement).to receive(:find) { achievement }
      end
      
      describe "GET edit" do
        before do
          get :edit, id: achievement
        end
        
        it "renders edit template" do
          expect(response).to render_template :edit
        end

        it "sets achievement for edit template" do
          expect(assigns[:achievement]).to eq achievement 
        end
      end

      describe "PUT update" do
        context "valid input" do
          let(:achievement_params) { {title: "new title"} }

          before do
            allow(achievement).to receive(:update).with(achievement_params) { true }
            put :update, id: achievement, achievement: achievement_params
          end

          it "redirect to achievement page" do
            expect(response).to redirect_to achievement_path(achievement)
          end
        end

        context "invalid input" do
          let(:achievement_params) { {title: ""} }

          before do
            allow(achievement).to receive(:update).with(achievement_params) { false }
            put :update, id: achievement, achievement: achievement_params
          end

          it "render edit template" do
            expect(response).to render_template :edit
          end

          it "assigns achievement for edit template" do
            expect(assigns[:achievement]).to eq achievement
          end
        end
      end

      describe "DELETE destroy" do
        before do
          allow(achievement).to receive(:destroy) { true }
        end

        it "redirects to achievements page" do
          delete :destroy, id: achievement
          expect(response).to redirect_to achievements_path
        end
      end
    end
  end
end