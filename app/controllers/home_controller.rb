class HomeController < ApplicationController
  def index
    @users = User.all(:limit => 30, :order => "RAND()")
		@featured_users = User.featured.all(:limit=>4,:order=>"RAND()")
		@posts = Blog.recent.super_user_posts.all(:limit=>4)
  end
end
