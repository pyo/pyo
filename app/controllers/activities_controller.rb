class ActivitiesController < ApplicationController
  
  def index
    
    conditions = nil
    if params[:type]
      conditions = case params[:type]
      when 'statuses' then ["consumer_type = 'User' and consumer_id = ? and type = ?", current_user.id, "StatusActivity"]
      when 'pictures' then ["consumer_type = 'User' and consumer_id = ? and type = ? and payload_type = ?", current_user.id, "MediaUploadActivity", "Photo"]
      when 'audios' then ["consumer_type = 'User' and consumer_id = ? and type = ? and payload_type = ?", current_user.id, "MediaUploadActivity", "Track"]
      when 'videos' then ["consumer_type = 'User' and consumer_id = ? and type = ? and payload_type = ?", current_user.id, "MediaUploadActivity", "Video"]
      when 'blogs' then ["consumer_type = 'User' and consumer_id = ? and type = ? and payload_type = ?", current_user.id, "MediaUploadActivity", "Blog"]
      when 'comments' then ["consumer_type = 'User' and consumer_id = ? and type = ?", current_user.id, "CommentActivity"]
      when 'follows' then ["consumer_type = 'User' and consumer_id = ? and type = ?", current_user.id, "FollowingActivity"]
      when 'likes' then ["consumer_type = 'User' and consumer_id = ? and type = ?", current_user.id, "LikeActivity"]
      end
    

    @activities = Activity.all(:include => [:producer => :profile], :conditions => conditions).paginate(:per_page => 25, :page => params[:page])
    
    respond_to do |format|
      format.js
    end
  end
  
  def create
    activity = StatusActivity.new(params[:activity])
    activity.producer = current_user
    activity.payload = current_user
    if activity.save
      flash[:notice] = "Your post was saved."
    else
      flash[:error] = "Your post was too long.  Please shorten your post and try again."
    end
    activity.save
    
    state = activity.id
    
    current_user.followers.each do |follower|
      activity = StatusActivity.new(params[:activity])
      activity.producer = current_user
      activity.consumer = follower
      activity.payload = current_user
      activity.state = state
      activity.save
    end
    
    redirect_to current_user
  end
  
  def destroy
    StatusActivity.destroy_all(["id = :id or state = :id", {:id => params[:id]}])
    redirect_to dashboard_path
  end
end
