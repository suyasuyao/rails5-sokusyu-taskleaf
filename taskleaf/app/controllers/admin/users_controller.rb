class Admin::UsersController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to admin_user_url(@user) ,  notice: "ユーザー「#{@user.name}」を登録しました。"
    else
      render :new
    end

  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update(user_params)

      redirect_to admin_user_url(@user) , notice: "ユーザー「#{@user.name}」を更新しました"
    else
      render :edit
    end

  end

  def show
    @user = User.find(params[:id])
  end

  def index
    @users = User.all
  end

  private

  def user_params
    # デバッグ用
    p "パラメータ: #{params} "
    p params.class
    params.require(:user).permit(:name, :email, :admin, :password, :password_confirmation)
  end
end
