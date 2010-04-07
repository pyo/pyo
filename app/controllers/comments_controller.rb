class CommentsController < ApplicationController
  
  def create
    @comment = Comment.new({:producer=>current_user}.merge(params[:comment]))
    if @comment.save
      flash[:notice] = "Comment was created."
      expire_fragment(:controller => 'users', :action => 'show', :id => current_user.to_param)
      redirect_to :back
    else
      flash[:error] = "Your comment wasn't saved. Make sure your character count is less than 300 characters."
      redirect_to :back
    end
  end
  
  def destroy
    @comment = Comment.find(params[:id])
    if is_owner? || @comment.consumer == current_user
      @comment.destroy
      flash[:notice] = "Comment was deleted."
      redirect_to :back
    else
      flash[:error] = "You are not authorized for that action."
      redirect_to :back
    end
  end
  
  private
    def is_owner?
      (current_user == @comment.producer)
    end
end
