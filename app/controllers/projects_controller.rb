class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :destroy]

  def index
    @projects = Project.all
  end

  def show
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render :show, status: :created, location: @project }
      else
        format.html { render :new }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def create_demoaccount
    10.times do |i|
      project = Project.new()
      project.username = "demoaccount-#{i}"
      project.github_id = "demoaccount-#{i}"
      project.twitter_id = "demoaccount"
      project.comment = "generated"
      project.save
    end


    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully created.' }
    end
  end

  def destroy_demoaccount
    10.times do |i|
      project = Project.find_by_username("demoaccount-#{i}")
      project.destroy
    end
    respond_to do |format|
      format.html { redirect_to projects_url, notice: 'Project was successfully destroyed.' }
    end
  end

  private
    def set_project
      @project = Project.find(params[:id])
    end

    def project_params
      params.require(:project).permit(:username, :github_id, :twitter_id, :comment)
    end
end
