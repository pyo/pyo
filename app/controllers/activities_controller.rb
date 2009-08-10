class ActivitiesController < ApplicationController
  def create
    activity = Activity.new(params[:activity])
    activity.producer = current_user
    activity.save
    redirect_to current_user
  end
end
