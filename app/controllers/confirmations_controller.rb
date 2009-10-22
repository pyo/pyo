class ConfirmationsController < ApplicationController
  include Clearance::App::Controllers::ConfirmationsController

  # overwrite Clearance to look for user by name rather than id

  def create
    @user = User.find_by_url_and_token(params[:user_id], params[:token])
    @user.confirm_email!

    sign_user_in(@user)
    flash[:notice] = "Your account has been confirmed! You may now use PYO."
    redirect_to url_after_create
  end
  
  private
  def forbid_confirmed_user
    user = User.find_by_url(params[:user_id])
    if user && user.email_confirmed?
      raise ActionController::Forbidden, "You have already confirmed your account."
    end
  end

  def forbid_non_existant_user
    unless User.find_by_url_and_token(params[:user_id], params[:token])
      raise ActionController::Forbidden, "Could not confirm account. You may have already confirmed your account."
    end
  end
  
  def url_after_create
    dashboard_path
  end
end
