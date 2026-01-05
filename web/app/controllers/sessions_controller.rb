class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_url, notice: "Logged in successfully"
    else
      redirect_to login_url, alert: "Invalid email or password"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_url, notice: "Logged out successfully"
  end
end
