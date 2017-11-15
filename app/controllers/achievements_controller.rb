class AchievementsController < ApplicationController
  def index
    @achievements = Achievement.public_access
  end

  def new
    @achievement = Achievement.new
  end

  def edit
    @achievement = Achievement.find(params[:id])
  end

  def update
    @achievement = Achievement.find(params[:id])

    if @achievement.update(achievement_params)
      redirect_to @achievement
    else
      render :edit
    end
  end

  def destroy
    if Achievement.destroy(params[:id])
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

  def achievement_params
    params.require(:achievement).permit!  
  end
end