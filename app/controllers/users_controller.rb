class UsersController < ApplicationController   
  include Clearance::App::Controllers::UsersController
  
  before_filter :authenticate_or_temp, :only => [:dashboard]
  
  before_filter :authenticate, :except => [:new, :create,:index,:show, :dashboard]
  before_filter :load_user, :only => [:show, :edit, :updates, :update, :follow, :unfollow, :connects, :likes, :inbox, :change_admin_status, :change_featured_status]
  before_filter :check_user, :only => [:edit,:update]
  after_filter :set_first_run, :only => [:dashboard]
  helper :notifications
  
  def index
		@title = "Members"
    @users = User.sort_by(params[:sort]).paginate(:include => :profile, :per_page => 40, :page => params[:page])
  end
  
  def likes
		@title = "#{@user.name.capitalize.possesive} Likes"
    @likes = @user.likes.paginate(:per_page => 15, :page => params[:page], :order => 'created_at desc')
    @posts = @user.blogs.paginate(:per_page => 5, :page => 1)
    @groups = @user.groups.paginate(:per_page => 5, :page => 1)
    @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ?", @user.id]).paginate(:per_page => 12, :page => 1)
  end
  
  def dashboard
		@title = "Dashboard"
    if current_user.email_confirmed?
      conditions = nil
      if params[:type]
        conditions = case params[:type]
        when 'statuses' then ["consumer_type = 'User' and consumer_id = ? and type = ?", current_user.id, "StatusActivity"]
        when 'pictures' then ["consumer_type = 'User' and consumer_id = ? and type = ? and payload_type = ?", current_user.id, "MediaUploadActivity", "Photo"]
        when 'audios' then ["consumer_type = 'User' and consumer_id = ? and type = ? and payload_type = ?", current_user.id, "MediaUploadActivity", "Track"]
        when 'videos' then ["consumer_type = 'User' and consumer_id = ? and type = ? and payload_type = ?", current_user.id, "MediaUploadActivity", "Video"]
        when 'blogs' then ["consumer_type = 'User' and consumer_id = ? and type = ? and payload_type = ?", current_user.id, "MediaUploadActivity", "Blog"]
        when 'comments' then ["consumer_type = 'User' and consumer_id = ? and type = ?", current_user.id, "CommentActivity"]
        when 'follows' then ["consumer_type = 'User' and consumer_id = ? and type = ?", current_user.id, "FollowingActivity"]
        when 'likes' then ["consumer_type = 'User' and consumer_id = ? and type = ?", current_user.id, "LikeActivity"]
        end
      else conditions = ["consumer_type = 'User' and consumer_id = ?", current_user.id]
      end

			@title << format_title_by_type(params[:type])
      
      @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ? and parent_type = 'User'", current_user.id])
      @activities = Activity.all(:include => [:producer => :profile], :conditions => conditions).paginate(:per_page => 25, :page => 1)
      @new_messages_count = current_user.new_messages.count
      @new_followings_count = current_user.new_followings.count
      @new_comments_count = current_user.new_comments.count
      @has_alerts = (@new_messages_count + @new_followings_count + @new_comments_count) > 0
    else
      render 'dashboard_tmp'
    end
  end
  
  def inbox
    @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ?", current_user.id]).paginate(:per_page => 12, :page => 1)
    @messages = current_user.messages.unread unless params[:mbox]
    @messages = current_user.messages.read   if (params[:mbox]=="archive")
    @messages = current_user.sent_messages   if (params[:mbox]=="sent")
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
		@title					= "#{@user.name.capitalize} (#{@user.profile.full_name})"
		@photos         = @user.photos.recent.paginate(:per_page => 10, :page => 1)
		@flickr_photos  = @user.flickr_photos(8)
		@tracks         = @user.tracks.paginate(:per_page => 6, :page => 1)
		@videos         = @user.videos.paginate(:per_page => 8, :page => 1)
		@tweets         = @user.tweets rescue []    
		@updates = Activity.all(:include => :payload, :conditions => ["producer_id = ? and producer_type = 'User' and consumer_id is NULL and type != 'FollowingActivity'", @user.id]).paginate(:per_page => 10, :page => 1)

		unless fragment_exist?(:controller => 'users', :action => 'show', :id => @user.to_param, :action_suffix => 'comments')
      @comments = Comment.all(:include => [:comments, {:producer => :profile}], :conditions => ["consumer_id = ? and consumer_type = 'User'", @user.id]).paginate(:per_page => 10, :page => 1)
    end
    unless fragment_exist?(:controller => 'users', :action => 'show', :id => @user.to_param, :action_suffix => 'followings')
      @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ?", @user.id]).paginate(:per_page => 12, :page => 1)
    end
    @posts          = @user.blogs.paginate(:per_page => 5, :page => 1)
    @groups         = @user.groups.paginate(:per_page => 5, :page => 1)
    @user.profile.update_view_count(request)
  end

  def updates
    @updates = @user.updates.paginate(:per_page => 25, :page => params[:page])
    @posts = @user.blogs.paginate(:per_page => 5, :page => 1)
    @groups = @user.groups.paginate(:per_page => 5, :page => 1)
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
    if @user.update_attributes(params[:user])
      flash[:notice] = "Profile was updated."
      redirect_to dashboard_path
    else
      @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ?", @user.id]).paginate(:per_page => 12, :page => 1)
      flash[:notice] = "Profile update failed."
			render :action => "edit"
    end
  end
  
  def follow
    expire_fragment(
      :controller => 'users', 
      :action => 'show', 
      :id => current_user.to_param, 
      :action_suffix => 'followings'
    )
    Following.create(:parent => current_user, :child => @user)
    redirect_to @user
  end
  
  def unfollow
    expire_fragment(
      :controller => 'users', 
      :action => 'show', 
      :id => current_user.to_param, 
      :action_suffix => 'followings'
    )
    Following.find_by_parent_and_child(current_user, @user).destroy
    redirect_to @user
  end
  
  def followers
    @user = User.find_by_url(params[:id])
		@title = "#{@user.name.capitalize.possesive} Followers"
    @followers = @user.followers.paginate(:per_page => 40, :page => params[:page])
    @posts = @user.blogs.paginate(:per_page => 5, :page => 1)
    @groups = @user.groups.paginate(:per_page => 5, :page => 1)
    @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ?", @user.id]).paginate(:per_page => 12, :page => 1)
  end
  
  def following
    @user = User.find_by_url(params[:id])
		@title ="Profiles #{@user.name.capitalize.possesive} is Following"
    @followings = @user.followings.paginate(:per_page => 40, :page => params[:page])
    @posts = @user.blogs.paginate(:per_page => 5, :page => 1)
    @groups = @user.groups.paginate(:per_page => 5, :page => 1)
  end
  
  def connects
    
		@title = "#{@user.name.capitalize.possesive} Connects" if @user
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
    @posts = @user.blogs.paginate(:per_page => 5, :page => 1)
    @groups = @user.groups.paginate(:per_page => 5, :page => 1)
    @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ?", @user.id]).paginate(:per_page => 12, :page => 1)
  end
  
  private
  
    def authenticate_or_temp
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
      @user = User.find_by_url(params[:id])
      unless @user
        flash[:notice] = "That user does not exists"
        redirect_to(page_not_found_path)
      end
      logger.info params.inspect
    end

		def format_title_by_type type
			" &mdash; " << case type
			when 'statuses' then "Status Updates"
			when 'pictures' then "Picture Updates"
			when 'audios' then "Picture Updates"
			when 'videos' then "Video Updates"
			when 'blogs' then "Blog Post Updates"
			when 'comments' then "Comment Updates"
			when 'follows' then "Follow Updates"
			when 'likes' then "Like Updates"
			else 
				return ''
			end		
		end
end