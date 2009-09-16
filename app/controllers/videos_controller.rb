class VideosController < ApplicationController
  before_filter :find_video, :except=>[:done,:status,:status_update]
  before_filter :find_user, :except => [:status_update]
  before_filter :check_user, :only => [:new, :create, :rate]
  before_filter :authenticate, :except => [:show, :index, :status_update]
  protect_from_forgery :except => :status_update
  
  def index
		@title = "#{@user.name.capitalize.possesive} Videos"
    @videos = @user.nil? ? Video.finished.all : @user.videos.finished.all
    @posts = @user.blogs.paginate(:per_page => 5, :page => 1)
    @groups = @user.groups.paginate(:per_page => 5, :page => 1)
    @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ?", @user.id]).paginate(:per_page => 12, :page => 1)
  end
  
  def like
    current_user.likes.create(:media => @video)
    expire_fragment(:controller => 'users', :action => 'show', :id => current_user.to_param)
    flash[:notice] = "You now like this video"
    redirect_to user_video_path(@video.user, @video)
  end
  
  def unlike
    Like.destroy_all(:user_id => current_user.id, :media_type => 'Video', :media_id => @video.id)
    LikeActivity.destroy_all(:producer_type => 'User', :producer_id => current_user.id, :payload_type => 'Video', :payload_id => @video.id)
    expire_fragment(:controller => 'users', :action => 'show', :id => current_user.to_param)
    flash[:notice] = "You no longer like this video"
    redirect_to user_video_path(@video.user, @video)
  end
  
  def videos
		@title = "Videos"
    @videos = Video.finished.paginate(:per_page => 25, :page => params[:page])
  end
  
  def new
    @video = current_user.videos.new
    @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ?", current_user.id]).paginate(:per_page => 12, :page => 1)
  end
  
  def create
    @panda_video = Panda::Video.create
    @video = current_user.videos.create(params[:video].merge({:panda_id => @panda_video.id, :finished => false}))
    if @video.errors.empty?
      redirect_to upload_user_video_path(current_user,@video)
    else
      render 'new'
    end
  end
  
  def rate
    @video.rate_it( params[:rate_value], current_user.id )
    respond_to do |wants|
      wants.json { 
        render :json => @video
      }
    end
  end
  
  def upload
    @upload_form_url = %(http://#{Panda.api_domain}:#{Panda.api_port}/videos/#{@video.panda_id}/form)
  end
  
  def done
    #@video = Video.unfinished(:first, :conditions => {:panda_id => params[:id]}) # Video.find_by_panda_id(params[:id])
    #@video.update_attribute(:finished, true)
    flash[:notice] = "Your video has successfully been uploaded and it will be posted to your profile once it is encoded."
    render :layout => false
  end
  
  def status
    @video = Video.find_by_panda_id(params[:id])
    @panda_video = Panda::Video.new_with_attrs(YAML.load(params[:video])[:video])
    @video.update_panda_status(@panda_video)
  end
  
  def status_update
    @video = Video.first(:conditions => {:panda_id => params[:id]}) # Video.find_by_panda_id(params[:id])
    @video.update_attribute(:finished, true)
    #@video = Video.find_by_panda_id(params[:id])
    @panda_video = Panda::Video.new_with_attrs(YAML.load(params[:video])[:video])
    @video.update_panda_status(@panda_video)
    expire_fragment(:controller => 'users', :action => 'show', :id => @video.user.to_param)
  end
  
  def show
    begin
      @panda_video = Panda::Video.find(@video.panda_id)
      @video.update_panda_status(@panda_video) if RAILS_ENV == 'development'
    rescue
      flash[:notice] = "The video could not be found"
      redirect_to(videos_path)
    end
		@title = @video.title
    @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ?", @user.id]).paginate(:per_page => 12, :page => 1)
    @posts = @user.blogs.paginate(:per_page => 5, :page => 1)
    @groups = @user.groups.paginate(:per_page => 5, :page => 1)
  end

	def update
		respond_to do |format|
			if @video.update_attributes(params[:video])
				format.html{ redirect_to [@user, @video] }
			else
				format.html{ render :action=>'edit' }
			end
		end
	end
	
	def destroy
    if is_owner?
      @video.destroy
      flash[:notice] = "Video was deleted."
      redirect_to :back
    else
      flash[:error] = "You are not authorized for that action."
      redirect_to :back
    end
	end
  
  private
    def find_video
      @video = Video.find(params[:id]) if params[:id]
    end
    
    def find_user
      @user = User.find_by_name(params[:user_id]) if params[:user_id]
    end
    
    def check_user
      current_user == @user
    end
    
    def is_owner?
      (current_user == @video.user)
  	end
  
end
