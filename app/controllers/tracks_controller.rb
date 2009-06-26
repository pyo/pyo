class TracksController < ApplicationController
  before_filter :find_track
  before_filter :find_user
  before_filter :check_user, :only => [:new, :create]
  
  def index
    @tracks = @user.tracks.all
  end
  
  def music
    @tracks = Track.all
  end
  
  def new
    @track = Track.new
  end
  
  def show
    
  end
  
  def create    
    @track = @user.tracks.new(params[:track]) 
     
    if @track.save
      flash[:notice] = 'Track was successfully created.'
      redirect_to user_track_path(@user,@track)
    else
      flash[:error] = @track.errors
      render :action => "new"
    end
  end
  
  private
    def find_track
      @track = Track.find(params[:id]) if params[:id]
    end
    
    def find_user
      @user = User.find_by_name(params[:user_id]) if params[:user_id]
    end
    
    def check_user
      current_user == @user
    end
end
