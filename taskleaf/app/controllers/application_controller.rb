class ApplicationController < ActionController::Base
  helper_method :current_user

  private

  def current_user

    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
    p @current_user
    p session[:user_id]
    @current_user
  end
end
