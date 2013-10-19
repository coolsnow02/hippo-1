class SessionsController < ApplicationController


  def create  # For Guest login Session
    @user = params[:user] ? User.find_or_initialize_by_email(params[:user][:email]) : User.new_guest
    if @user.save
      current_user.move_to(@user) if current_user && current_user.guest?
      session[:user_id] = @user.id
      redirect_to root_url, :notice => "Successfuly login as Guest"
    else
      render "new"
    end
  end

  def destroy #for Guest Logout
    session[:user_id] = nil
    redirect_to root_url, notice: "Logged out!"
  end
end