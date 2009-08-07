module NotificationsHelper
  def display_notification(notification)
    unless notification.flavor.blank?
      render :partial => "activities/#{notification.flavor}",:locals=>{:item=>notification.payload}
    else
      render :partial => "activities/default",:locals=>{:item=>notification}
    end
  end
end
