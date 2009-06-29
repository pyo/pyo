module NotificationsHelper
  def display_notification(notification)
    case [notification.class, notification.flavor]
    when [Alert, 'following'] then "is now following you"
    when [Activity, 'comment'] then "has commented on your profile"
    when [Activity, 'track'] then "has posted the track #{link_to(h(notification.payload.name), user_track_path(notification.payload.user, notification.payload))}. "
    when [Activity, 'photo'] then "posted the photo <br> #{link_to(image_tag(notification.payload.image.url(:thumb), :width=>'60'), user_photo_path(notification.payload.user, notification.payload))}"
    end
  end
end
