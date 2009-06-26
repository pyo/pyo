class CommentsController < ApplicationController
  
  def create
    Comment.create({:producer=>current_user}.merge(params[:comment]))
    redirect_to :back
  end
  
end
