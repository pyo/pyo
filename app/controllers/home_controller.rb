class HomeController < ApplicationController
  def index
		@users = User.featured.all(:limit=>4,:order=>"RAND()")
  end
end
