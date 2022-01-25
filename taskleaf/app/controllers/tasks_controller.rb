class TasksController < ApplicationController
  def index
    @tasks = current_user.tasks.order(created_at: :desc)
  end

  def show
    # p params
    @task = current_user.tasks.find(params[:id])
  end

  def new
    @task = current_user.tasks.new
  end

  def create
    @task = current_user.tasks.new(task_params)

    if @task.save
      #redirect先を@taskにすべきかどうか？ｘ
      redirect_to @task,  notice: "タスク「#{@task.name}」を登録しました。"
    else
      render :new
    end

  end

  def edit
    @task = current_user.tasks.find(params[:id])
  end

  def update
    @task = current_user.tasks.find(params[:id])
    # task.update(task_params)
    # redirect_to tasks_url, notice: "タスク「#{task.name}」を更新しました。"

    if @task.update(task_params)
      #redirect先を@taskにすべきかどうか？ｘ
      redirect_to @task,  notice: "タスク「#{@task.name}」を更新しました。"
    else
      render :edit
    end
  end

  def destroy
    @task = current_user.tasks.find(params[:id])
    @task.destroy
    redirect_to tasks_url, notice: "タスク「#{@task.name}」を削除しました。"
  end

  private

  def task_params
    # デバッグ用
    p "パラメータ: #{params} "
    p params.class
    params.require(:task).permit(:name, :description)
  end
end
