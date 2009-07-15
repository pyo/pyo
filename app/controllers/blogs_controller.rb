class BlogsController < ApplicationController
  before_filter :find_blog
  before_filter :find_user
  before_filter :check_user, :only => [:new, :create]
  before_filter :authenticate, :except => [:show, :index]
  
  
  def index
    @blogs = @user.blogs.all
  end
  
  
  def new
    @blog = @user.blogs.new
  end
  
  def edit
    
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
    @blog = @user.blogs.new(params[:blog]) 
     
    if @blog.save
      flash[:notice] = 'Blog was successfully created.'
      redirect_to user_blog_path(@user,@blog)
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
