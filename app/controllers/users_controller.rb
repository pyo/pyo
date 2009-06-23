class UsersController < ApplicationController   
  include Clearance::App::Controllers::UsersController
  def index
    @users = User.all
  end
  def dashboard
  end
  
  def show
    @user = User.find_by_name(params[:id])
  end
end