class VideosController < ApplicationController
  
  def index
  end
  
  def new
    @video = Video.new
  end
  
  def create
    @panda_video = Panda::Video.create
    @video = Video.create(params[:video].merge({:panda_id => @panda_video.id}))
    redirect_to :action => :upload, :id => @video.id
  end
  
  def upload
    @video = Video.find(params[:id])
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
  
  def show
    @video = Video.find(params[:id])
    @panda_video = Panda::Video.find(@video.panda_id)
    @video.update_panda_status(@panda_video) if RAILS_ENV == 'development'
  end
  
  
end
