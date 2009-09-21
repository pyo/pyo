# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Clearance::App::Controllers::ApplicationController
  helper :all # include all helpers, all the time

  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
	def get_users_recent_assets
		if @user
			@recent_tracks = @user.tracks.recent(:limit=>4)
			@recent_photos = @user.photos.recent(:limit=>4)
			@recent_videos = @user.videos.recent(:limit=>4)
		end
	end
  
  # Helper methods for polymorphism in controllers
  class << self
    attr_reader :parents
    def parent_resources(*parents)
      @parents = parents
    end
  end

  def parent_id(parent)
    request.path_parameters["#{ parent }_id"]
  end

  def parent_type
    self.class.parents.detect { |parent| parent_id(parent) }
  end

  def parent_class
    parent_type && parent_type.to_s.classify.constantize
  end

  def parent_object
    parent_class && parent_class.find_by_id(parent_id(parent_type))
  end
  
  def expire_cache_for(user)
    expire_fragment :controller => "users", :action => "show", :id => user.to_param
  end

	protected
    
   def find_user
     @user = User.find_by_url(params[:user_id]) if params[:user_id]
     @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ?", @user.id]).paginate(:per_page => 12, :page => 1) if @user
   end
end
