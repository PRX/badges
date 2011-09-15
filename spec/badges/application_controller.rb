class ApplicationController  < ActionController::Base

  def current_user
    @current_user
  end
  
  def current_user=(user)
    @current_user = user
  end

end