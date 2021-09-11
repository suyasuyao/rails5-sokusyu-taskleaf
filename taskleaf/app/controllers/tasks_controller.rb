class TasksController < ApplicationController
  def index
    @tasks = Task.all
  end

  def show
    # p params
    @task = Task.find(params[:id])
  end

  def new
    @task = Task.new
  end

  def create
    task = Task.new(task_params)
    task.save!
    redirect_to tasks_url, notice: "タスク「#{task.name}を登録しました。"
  end

  def edit; end

  private

  def task_params
    # デバッグ用
    p "パラメータ: #{params} "
    p params.class
    params.require(:task).permit(:name, :description)
  end
end
