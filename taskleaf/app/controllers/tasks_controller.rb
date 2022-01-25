class TasksController < ApplicationController
  def index
    @tasks = current_user.tasks.order(created_at: :desc)
  end

  def show
    set_task
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
    set_task
  end

  def update
    set_task
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
    set_task
    @task.destroy
    redirect_to tasks_url, notice: "タスク「#{@task.name}」を削除しました。"
  end

  private

  def set_task
    @task = current_user.tasks.find(params[:id])
  end

  def task_params
    # デバッグ用
    p "パラメータ: #{params} "
    p params.class
    params.require(:task).permit(:name, :description)
  end
end
