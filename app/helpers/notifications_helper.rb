module NotificationsHelper
  def display_notification(notification)
    unless notification.type.blank?
      render :partial => "activities/#{notification.flavor.downcase.gsub(/activity$/,'')}",:locals=>{:item=>notification}
    else
      render :partial => "activities/default",:locals=>{:item=>notification}
    end
  end
end
