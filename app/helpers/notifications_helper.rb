module NotificationsHelper
  def display_notification(notification)
    render :partial => "activities/#{notification.flavor}",:locals=>{:item=>notification.payload}
  end
end
