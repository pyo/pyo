class CommentsController < ApplicationController
  
  before_filter :load_user, :only => [:create]
  
  def create
    Comment.create({:producer => current_user, :consumer => @user}.merge(params[:comment]))
    redirect_to @user
  end
  
  private
  def load_user
    @user = User.find_by_name(params[:user_id])
  end
end
