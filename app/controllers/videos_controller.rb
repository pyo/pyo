class VideosController < ApplicationController
  before_filter :find_video, :except=>[:done,:status,:status_update]
  before_filter :find_user
  before_filter :check_user, :only => [:new, :create, :rate]
  before_filter :authenticate, :except => [:show, :index]
  protect_from_forgery :except => :status_update
  
  def index
    @videos = @user.nil? ? Video.all : @user.videos.all
  end
  
  def new
    @video = @user.videos.new
  end
  
  def create
    @panda_video = Panda::Video.create
    @video = @user.videos.create(params[:video].merge({:panda_id => @panda_video.id}))
    redirect_to upload_user_video_path(@user,@video)
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
    @video = Video.find_by_panda_id(params[:id])
    render :layout => false
  end
  
  def status
    @video = Video.find_by_panda_id(params[:id])
    @panda_video = Panda::Video.new_with_attrs(YAML.load(params[:video])[:video])
    @video.update_panda_status(@panda_video)
  end
  
  def status_update
    @video = Video.find_by_panda_id(params[:id])
    @panda_video = Panda::Video.new_with_attrs(YAML.load(params[:video])[:video])
    @video.update_panda_status(@panda_video)
  end
  
  def show
    @panda_video = Panda::Video.find(@video.panda_id)
    @video.update_panda_status(@panda_video) if RAILS_ENV == 'development'
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
