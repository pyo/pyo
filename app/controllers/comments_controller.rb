class CommentsController < ApplicationController
  
  def create
    params[:comment][:producer] = current_user
    Comment.create(params[:comment])
    redirect_to :back
  end
  
end
