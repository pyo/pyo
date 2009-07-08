class DirectMessagesController < ApplicationController
  before_filter :authenticate
  before_filter :find_direct_message, :only => [:show]
  before_filter :find_user, :only => [:new,:create,:show]
  before_filter :check_user, :only => [:show,:destroy]
  
  def new
    @direct_message = DirectMessage.new
  end

  def create
    @direct_message = @user.messages.new(params[:direct_message])
    if @direct_message.save
      flash[:notice] = "Message sent."
      redirect_to @user
    else
      flash[:error] = "Error sending message."
      redirect_to new_user_direct_message_path(@user)
    end
  end
  
  def show
    @direct_message.state = "read"
    @direct_message.save
  end

  private
    def check_user
      unless (@direct_message.consumer == current_user)
        flash[:error] = "You are not authorized for that action."
        redirect_to "/"
      end
    end
    def find_user
      @user = User.find_by_name(params[:user_id])
    end
    def find_direct_message
      @direct_message = DirectMessage.find(params[:id]) if params[:id]
    end
end
