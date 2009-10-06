class PhotosController < ApplicationController
  before_filter :find_photo
  before_filter :find_user
  before_filter :check_user, :only => [:new, :create, :rate]
  before_filter :authenticate, :except => [:show, :index]
  
  def index
		@title = "#{@user.name.capitalize.possesive} Pictures"
    @photos = @user.photos.paginate(:per_page => 30, :page => params[:page])
    load_user_data
  end
  
  def like
    current_user.likes.create(:media => @photo)
    expire_fragment(:controller => 'users', :action => 'show', :id => current_user.to_param)
    flash[:notice] = "You now like this photo"
    redirect_to user_photo_path(@photo.user, @photo)
  end
  
  def unlike
    Like.destroy_all(:user_id => current_user.id, :media_type => 'Photo', :media_id => @photo.id)
    LikeActivity.destroy_all(:producer_type => 'User', :producer_id => current_user.id, :payload_type => 'Photo', :payload_id => @photo.id)
    expire_fragment(:controller => 'users', :action => 'show', :id => current_user.to_param)
    flash[:notice] = "You no longer like this photo"
    redirect_to user_photo_path(@photo.user, @photo)
  end

  def new
    @title = "Upload Pictures"
    @photo = Photo.new
    @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ?", current_user.id]).paginate(:per_page => 12, :page => 1)
  end
  
  def show
		@title = @photo.title
    @prev_photo = @user.photos.first(:order => 'id desc', :conditions => ["id < ?", @photo.id])
    @next_photo = @user.photos.first(:order => 'id asc', :conditions => ["id > ?", @photo.id])
    load_user_data
  end
  
  def rate
    @photo.rate_it( params[:rate_value], current_user.id )
    respond_to do |wants|
      wants.json { 
        render :json => @photo
      }
    end
  end
  
  def create    
    @photo = current_user.photos.new(params[:photo])  
    if @photo.save
      expire_fragment(:controller => 'users', :action => 'show', :id => current_user.to_param)
      flash[:notice] = 'Your picture has successfully been uploaded and posted to your profile.'
      redirect_to dashboard_path
    else
      flash[:error] = "There was a problem with your submission"
      render :action => "new"
    end
  end
  
  
  def destroy
    if is_owner?
      @photo.destroy
      flash[:notice] = "Comment was deleted."
      redirect_to :back
    else
      flash[:error] = "You are not authorized for that action."
      redirect_to :back
    end
  end
  

  private
    def find_photo
      @photo = Photo.find(params[:id]) if params[:id]
    end
    
    def find_user
      @user = User.find_by_url(params[:user_id]) if params[:user_id]
    end
    
    def check_user
      current_user == @user
    end
    
    def is_owner?
      (current_user == @photo.user)
    end
    
    
    def load_user_data
      @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ?", @user.id]).paginate(:per_page => 12, :page => 1)
      @posts = @user.blogs.paginate(:per_page => 5, :page => 1)
      @groups = @user.groups.paginate(:per_page => 5, :page => 1)
    end
end


