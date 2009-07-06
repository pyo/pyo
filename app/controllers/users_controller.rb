class UsersController < ApplicationController   
  include Clearance::App::Controllers::UsersController
  before_filter :authenticate, :except => [:new, :create]
  before_filter :load_user, :only => [:show, :edit, :update, :follow, :connects]
  after_filter :set_first_run, :only => [:dashboard]
  helper :notifications
  
  def index
    @users = User.all
  end
  
  def dashboard
  end
  
  def connects
    @connects = @user.followings
  end
  
  def new
    @user = User.new(params[:user])
    @user.profile = Profile.new
  end
  
  def create
    params[:user][:profile_attributes][:username] = params[:user][:name]
    @user = User.new params[:user]
    if @user.save
      ClearanceMailer.deliver_confirmation @user
      flash[:notice] = "You will receive an email within the next few minutes. " <<
                       "It contains instructions for confirming your account."
      redirect_to url_after_create
    else
      render :action => "new"
    end
  end
  
  def edit
    @profile = @user.profile || Profile.new
  end
  
  def show
    @photos = @user.photos.recent(:limit => 6)
    @tracks = @user.tracks.recent(:limit => 10)
    @videos = []
  end
  
  def update
    @user.update_attributes(params[:user])
    redirect_to dashboard_path
  end
  
  def follow
    Following.create(:parent => current_user, :child => @user)
    redirect_to @user
  end
  
  private
  
    def set_first_run
      if current_user.first_run
        current_user.first_run = false   
        current_user.save 
      end
    end
  
    def load_user
      @user = User.find_by_name(params[:id])
      logger.info params.inspect
    end
end