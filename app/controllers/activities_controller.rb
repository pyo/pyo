class ActivitiesController < ApplicationController
  
  def index
    @activities = current_user.all_activities.paginate(:per_page => 1, :page => params[:page])
    respond_to do |format|
      format.js
    end
  end
  
  def create
    activity = StatusActivity.new(params[:activity])
    activity.producer = current_user
    activity.save
    redirect_to current_user
  end
end
