class BlogsController < ApplicationController
  before_filter :find_blog
  before_filter :find_user
  # before_filter :check_user, :only => [:new, :create]
  before_filter :authenticate, :except => [:show, :index]
  
  
  def index
    @blogs = @user.blogs.all
  end
  
  
  def new
    @title = "Put Yourself On - Post New Blog"
    @blog = current_user.blogs.new
  end
  
  def edit
    
  end
  
  def show
    @user = @blog.user
    @title = @blog.title
    @followings = User.all(:include => :profile, :joins => "INNER JOIN followings ON ( users.id = followings.child_id AND followings.child_type = 'User')", :conditions => ["parent_id = ?", @user.id]).paginate(:per_page => 12, :page => 1)
    @posts = @user.blogs.paginate(:per_page => 5, :page => 1)
    @groups = @user.groups.paginate(:per_page => 5, :page => 1)
  end
  
  def update
    if @blog.update_attributes(params[:blog])
      flash[:notice] = 'Blog was successfully updated.'
      redirect_to user_blog_path(@user,@blog)
    else
      flash[:error] = @blog.errors
      render :action => "edit"
    end
  end
  
  
  def create    
    @blog = current_user.blogs.new(params[:blog]) 
     
    if @blog.save
      expire_fragment(:controller => 'users', :action => 'show', :id => current_user.to_param)
      flash[:notice] = 'Your blog has successfully been posted to your profile.'
      redirect_to dashboard_path
    else
      flash[:error] = @blog.errors
      render :action => "new"
    end
  end
  
  def destroy
    if is_owner?
      @blog.destroy
      flash[:notice] = "Blog was deleted."
      redirect_to :back
    else
      flash[:error] = "You are not authorized for that action."
      redirect_to :back
    end
  end
  
  def rate
    @blog.rate_it( params[:rate_value], current_user.id )
    respond_to do |wants|
      wants.json { 
        render :json => @blog
      }
    end
  end
  
  private
    def find_blog
      @blog = Blog.find(params[:id]) if params[:id]
    end
    
    def check_user
      unless current_user == @user
        redirect_to "/"
      end
    end
    
    def is_owner?
      (current_user == @blog.user)
    end
end
