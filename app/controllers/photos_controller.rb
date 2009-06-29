class PhotosController < ApplicationController
  before_filter :find_photo
  before_filter :find_user
  before_filter :check_user, :only => [:new, :create]
  
  def index
    @photos = @user.photos.all
  end

  def new
    @photo = Photo.new
  end
  
  def show
    
  end
  
  def create    
    @photo = @user.photos.new(params[:photo])  
    if @photo.save
      flash[:notice] = 'Photo was successfully created.'
      redirect_to user_photo_path(@user,@photo)
    else
      flash[:error] = @photo.errors
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
      @user = User.find_by_name(params[:user_id]) if params[:user_id]
    end
    
    def check_user
      current_user == @user
    end
    
    def is_owner?
      (current_user == @photo.user)
    end
    
end


