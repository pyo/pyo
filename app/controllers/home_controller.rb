class HomeController < ApplicationController
  def index
    @users = User.all(:limit => 30, :order => "RAND()")
    @featured_users = User.all(:limit=>4,:order=>"RAND()")
		#@featured_users = User.featured.all(:limit=>4,:order=>"RAND()")
		@posts = Blog.recent.super_user_posts.all(:limit=>4)
  end
  
  def about
		@title = "About Us"
  end
  
  def privacy_policy
    @title = "Privacy Policy"
  end

  def page_not_found
    @title = "You Lost?"
    flash[:notice] = 'The page you are looking for doesn\'t exist. You may have mistyped the address or the page may have moved.'
    respond_to do |type|
      type.html { render :template => 'home/page_not_found', :layout => 'application', :status => 404 }
      type.all  { render :nothing => true, :status => 404 }  
    end
  end

  def terms
    @title = "Terms of Use"
  end
  
  def contact
    @title = "Contact Us"
  end
  
  def faq
    @title = "Frequently Asked Questions"
  end
end
