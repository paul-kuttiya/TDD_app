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
      redirect_to @achievement
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
    @achievement = Achievement.new(achievement_params)

    if @achievement.save
      redirect_to @achievement, notice: "Achievement has been created"
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