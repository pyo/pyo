class SearchesController < ApplicationController
  def index
	
    klass = params['type'] ? params['type'].classify.constantize : ThinkingSphinx::Search  
    sort = nil
    case params[:sort_by]
    when 'created_at' then sort = 'created_at asc'
		else
			sort = "created_at desc"
    end
    
    classes = [Track, Photo, User, Video, Blog, Booking, Ad]
    
    if sort
      @results = klass.search params[:q], :classes => classes, :order => sort, :page => params[:page], :per_page => 20, :star => true
    else
      @results = klass.search params[:q], :classes => classes, :page => params[:page], :per_page => 20, :star => true
    end
    
  end
end