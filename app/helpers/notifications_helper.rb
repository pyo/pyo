module NotificationsHelper
  def display_notification(notification)
    case [notification.class, notification.flavor]
    when [Alert, 'following'] then "#{notification.producer.name} is now following you"
    when [Activity, 'comment'] then "#{link_to notification.producer.name, notification.producer} has commented on your profile"
    end
  end
end
