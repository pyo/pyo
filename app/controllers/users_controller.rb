class UsersController < ApplicationController   
  include Clearance::App::Controllers::UsersController
  before_filter :load_user, :only => [:show, :follow]
  helper :notifications
  def index
    @users = User.all
  end
  def dashboard
  end
  
  def show
  end
  
  def follow
    Following.create(:parent => current_user, :child => @user)
    redirect_to @user
  end
  
  private
  def load_user
    @user = User.find_by_name(params[:id])
  end
end