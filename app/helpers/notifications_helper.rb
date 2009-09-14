module NotificationsHelper
  def display_notification(notification)
    begin
      unless notification.type.blank?
        render :partial => "activities/#{notification.type.to_s.downcase.gsub(/activity$/,'')}",:locals=>{:item=>notification}
      else
        render :partial => "activities/default",:locals=>{:item=>notification}
      end
    rescue
      "Could not display type: #{notification.type.to_s.downcase.gsub(/activity$/,'')}"
    end
  end
end
