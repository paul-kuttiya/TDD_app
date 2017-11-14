class AchievementsController < ApplicationController
  def new
    @achievement = Achievement.new
  end

  def create
    @achievement = Achievement.new(achievement_params)

    if @achievement.save
      redirect_to root_path, notice: "Achievement has been created"
    else
      render :new
    end
  end

  def show
    @achievement = Achievement.find(params[:id])
    @description = Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(@achievement.description)
  end

  private

  def achievement_params
    params.require(:achievement).permit!  
  end
end