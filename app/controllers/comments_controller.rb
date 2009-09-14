class CommentsController < ApplicationController
  
  def create
    flash[:notice] = "Comment was created."
    expire_fragment(
      :controller => 'users', 
      :action => 'show', 
      :id => User.find(params[:comment][:consumer_id]).to_param, 
      :action_suffix => 'comments'
    )
    expire_fragment(:controller => 'users', :action => 'show', :id => current_user.to_param)
    Comment.create({:producer=>current_user}.merge(params[:comment]))
    redirect_to :back
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
