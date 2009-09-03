class ActivitiesController < ApplicationController
  
  def index
    
    conditions = nil
    if params[:type]
      conditions = case params[:type]
      when 'statuses' then ["type = ?", "StatusActivity"]
      when 'pictures' then ["type = ? and payload_type = ?", "MediaUploadActivity", "Photo"]
      when 'audios' then ["type = ? and payload_type = ?", "MediaUploadActivity", "Track"]
      when 'videos' then ["type = ? and payload_type = ?", "MediaUploadActivity", "Video"]
      when 'blogs' then ["type = ? and payload_type = ?", "MediaUploadActivity", "Blog"]
      when 'comments' then ["type = ?", "CommentActivity"]
      when 'follows' then ["type = ?", "FollowingActivity"]
      when 'likes' then ["type = ?", "LikeActivity"]
      end
    end
    @activities = current_user.activities.paginate(:per_page => 25, :page => params[:page], :conditions => conditions)
    respond_to do |format|
      format.js
    end
  end
  
  def create
    current_user.followers.each do |follower|
      activity = StatusActivity.new(params[:activity])
      activity.producer = current_user
      activity.consumer = follower
      activity.save
    end
    activity = StatusActivity.new(params[:activity])
    activity.producer = current_user
    activity.save
    redirect_to current_user
  end
end
