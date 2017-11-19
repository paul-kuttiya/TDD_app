class AchievementsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :owners_only, only: [:edit, :update, :destroy]

  def index
    @achievements = Achievement.public_access
  end

  def new
    @achievement = Achievement.new
  end

  def edit
  end

  def update
    if @achievement.update(achievement_params)
      redirect_to achievement_path(@achievement)
    else
      render :edit
    end
  end

  def destroy
    if @achievement.destroy
      redirect_to achievements_path
    end
  end

  def create
    @achievement = Achievement.new(achievement_params.merge(user: current_user))

    if @achievement.save
      UserMailer.achievement_created(current_user.email, @achievement.id).deliver_now
      
      tweet = TwitterService.new.tweet(@achievement.title)
      redirect_to achievement_path(@achievement), notice: "Achievement has been created. Tweeted achievement! at #{tweet.url}" 
    else
      render :new
    end
  end

  def show
    @achievement = Achievement.find(params[:id])
  end

  private

  def owners_only
    @achievement = Achievement.find(params[:id])
    
    if current_user != @achievement.user
      redirect_to achievements_path
    end
  end

  def achievement_params
    params.require(:achievement).permit!
  end
end