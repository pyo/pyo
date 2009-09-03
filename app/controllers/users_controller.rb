class UsersController < ApplicationController   
  include Clearance::App::Controllers::UsersController
  
  before_filter :authenticate_or_temp, :only => [:dashboard]
  
  before_filter :authenticate, :except => [:new, :create,:index,:show, :dashboard]
  before_filter :load_user, :only => [:show, :edit, :update, :follow, :connects, :likes, :inbox, :change_admin_status, :change_featured_status]
  before_filter :check_user, :only => [:edit,:inbox,:update]
  after_filter :set_first_run, :only => [:dashboard]
  helper :notifications
  
  def index
    @users = User.sort_by(params[:sort]).all
  end
  
  def likes
    @likes = @user.likes.paginate(:per_page => 15, :page => params[:page], :order => 'created_at desc')
    @posts = @user.blogs.paginate(:per_page => 5, :page => 1)
    @groups = @user.groups.paginate(:per_page => 5, :page => 1)
  end
  
  def dashboard
    logger.info current_user.inspect
    if current_user.email_confirmed?
      @activities = current_user.all_activities.paginate(:per_page => 25, :page => 1)
      @new_messages_count = current_user.new_messages.count
      @new_followings_count = current_user.new_followings.count
      @new_comments_count = current_user.new_comments.count
      @has_alerts = (@new_messages_count + @new_followings_count + @new_comments_count) > 0
    else
      render 'dashboard_tmp'
    end
  end
  
  def inbox
    @messages = current_user.messages.unread unless params[:mbox]
    @messages = current_user.messages.read   if (params[:mbox]=="archive")
    @messages = current_user.sent_messages   if (params[:mbox]=="sent")
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
      session[:temp_user_id] = @user.id
      redirect_to edit_profile_path(@user.profile)
    else
      render :action => "new"
    end
  end
  
  def edit
    @profile = @user.profile || Profile.new
  end
  
  def show
    @photos = @user.photos.recent.paginate(:per_page => 10, :page => 1)
    @flickr_photos = @user.flickr_photos(8)
    @tracks = @user.tracks.recent(:limit => 10)
    @videos = @user.videos
    @tweets = @user.tweets rescue [] 
    
    @followings = @user.followings.paginate(:per_page => 12, :page => 1)  
    @updates = @user.updates.paginate(:per_page => 24, :page => 1)
    @posts = @user.blogs.paginate(:per_page => 5, :page => 1)
    @groups = @user.groups.paginate(:per_page => 5, :page => 1)
    @user.profile.update_view_count(request)
    
  end

	def change_admin_status
		respond_to do |format|
	    if @user.update_attribute(:super_user, params[:user][:admin])
				format.js { head :ok }
	    else
				format.js { render :status=>500 }
	    end
		end
	end

	def change_featured_status
		respond_to do |format|
	    if @user.update_attribute(:featured, params[:user][:featured])
				format.js { head :ok }
	    else
				format.js { render :status=>500 }
	    end
		end
	end
  
  def update
		respond_to do |format|
	    if @user.update_attributes(params[:user])
	      flash[:notice] = "Profile was updated."
				format.html { redirect_to dashboard_path }
				format.js { head :ok }
	    else
	      flash[:notice] = "Profile update failed."
				format.html { render :action => "edit" }
				format.js { render :status=>500 }
	    end
		end
  end
  
  def follow
    Following.create(:parent => current_user, :child => @user)
    redirect_to @user
  end
  
  def followers
    @user = User.find_by_name(params[:id])
    @followers = @user.followers.paginate(:per_page => 40, :page => params[:page])
    @posts = @user.blogs.paginate(:per_page => 5, :page => 1)
    @groups = @user.groups.paginate(:per_page => 5, :page => 1)
  end
  
  def following
    @user = User.find_by_name(params[:id])
    @followings = @user.followings.paginate(:per_page => 40, :page => params[:page])
    @posts = @user.blogs.paginate(:per_page => 5, :page => 1)
    @groups = @user.groups.paginate(:per_page => 5, :page => 1)
  end
  
  def connects
    @user = current_user
    @connects = User.paginate(
      :select => 'distinct `users`.*',
      :per_page => 40,
      :page => params[:page],
      :joins => %{
        join followings as ls
        on
        (ls.parent_id = '#{current_user.id}' and users.id = ls.child_id)
        or
        (ls.child_id = '#{current_user.id}' and users.id = ls.parent_id)
        join followings as rs
        on
        (rs.parent_id = '#{current_user.id}' and rs.child_id = ls.parent_id and ls.child_id = '#{current_user.id}')
        or
        (rs.child_id = '#{current_user.id}' and rs.parent_id = ls.child_id and ls.parent_id = '#{current_user.id}')
      }
    )
    @posts = current_user.blogs.paginate(:per_page => 5, :page => 1)
    @groups = current_user.groups.paginate(:per_page => 5, :page => 1)
  end
  
  private
  
    def authenticate_or_temp
      logger.info "FOOK => #{session.inspect}"
      unless session[:temp_user_id]
        authenticate
      else
        @_current_user = User.find(session[:temp_user_id])
        unless current_user
          authenticate
        end
      end
    end
  
    def check_user
      unless current_user == @user || current_user.super_user?
        redirect_to "/"
      end
    end
  
    def set_first_run
      if current_user.first_run && current_user.email_confirmed?
        current_user.first_run = false   
        current_user.save 
      end
    end
  
    def load_user
      @user = User.find_by_name(params[:id])
      logger.info params.inspect
    end
end