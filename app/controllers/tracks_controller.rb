class TracksController < ApplicationController
  before_filter :find_track
  before_filter :find_user
  # before_filter :check_user, :only => [:new, :create]
  before_filter :authenticate, :except => [:show, :index, :music]
  
  def index
    @tracks = @user.tracks.all
    @posts = @user.blogs.paginate(:per_page => 5, :page => 1)
    @groups = @user.groups.paginate(:per_page => 5, :page => 1)
    @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ?", @user.id]).paginate(:per_page => 12, :page => 1)
  end
  
  def like
    current_user.likes.create(:media => @track)
    flash[:notice] = "You now like this track"
    redirect_to user_track_path(@track.user, @track)
  end
  
  def music
    @tracks = Track.all
  end
  
  def new
    @track = current_user.tracks.new
  end
  
  def show
    @posts = @user.blogs.paginate(:per_page => 5, :page => 1)
    @groups = @user.groups.paginate(:per_page => 5, :page => 1)
    @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ?", @user.id]).paginate(:per_page => 12, :page => 1)
  end
  
  def music
    @recent_tracks = Track.recent(:limit=>8)
    @popular_tracks = Track.popular(:limit=>8)
    
  end
  
  def rate
    @track.rate_it( params[:rate_value], current_user.id )
    respond_to do |wants|
      wants.json { 
        render :json => @track
      }
    end
  end
  
  def create    
    @track = current_user.tracks.new(params[:track]) 
     
    if @track.save
      expire_fragment(:controller => 'users', :action => 'show', :id => current_user.to_param)
      flash[:notice] = 'Your audio track has successfully been uploaded and posted to your profile.'
      redirect_to dashboard_path
    else
      flash[:error] = @track.errors
      render :action => "new"
    end
  end
  
  def destroy
    if is_owner?
      @track.destroy
      flash[:notice] = "Track was deleted."
      redirect_to :back
    else
      flash[:error] = "You are not authorized for that action."
      redirect_to :back
    end
  end
  
  
  private
    def find_track
      @track = Track.find(params[:id]) if params[:id]
    end
    
    def check_user
      unless current_user == @user
        redirect_to "/"
      end
    end
    
    def is_owner?
      (current_user == @track.user)
    end
end
