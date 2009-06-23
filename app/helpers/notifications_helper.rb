module NotificationsHelper
  def display_notification(notification)
    case notification.flavor
    when 'following' then "#{notification.producer.name} is now following you"
    end
  end
end
