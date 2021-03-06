class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authorize!
  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user

  def authorize!
    redirect_to root_path, alert: "Not authorized" unless current_user.present?
  end
end
