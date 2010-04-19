class UserMailer < ActionMailer::Base
  
  def direct_message(direct_message)  
    subject      "You have a new Direct Message"  
    from         direct_message.producer.name  
    recipients   direct_message.consumer.email  
    body         :direct_message => direct_message
  end
  
  def new_follower(following)
    subject    "You have a new follower"
    from       DO_NOT_REPLY
    recipients following.child
    body       :following => following
  end

  def photo_comment(photo, comment)
    subject      "A comment has been posted to your photo"
    from         DO_NOT_REPLY
    recipients   photo.user.email
    body         :photo   => photo,
                 :comment => comment
  end

  def user_comment(user, comment)
    subject      "A comment has been posted to your profile"
    from         DO_NOT_REPLY
    recipients   user.email
    body         :user    => user,
                 :comment => comment
  end

  def track_comment(track, comment)
    subject      "A comment has been posted to your audio track"
    from         DO_NOT_REPLY
    recipients   track.user.email
    body         :track    => track,
                 :comment => comment
  end

  def video_comment(video, comment)
    subject      "A comment has been posted to your video"
    from         DO_NOT_REPLY
    recipients   video.user.email
    body         :video   => video,
                 :comment => comment
  end

  def blog_comment(blog, comment)
    subject      "A comment has been posted to your blog"
    from         DO_NOT_REPLY
    recipients   blog.user.email
    body         :blog    => blog,
                 :comment => comment
  end

  def like_email(like)
    subject      "The user #{like.user.name} likes your #{like.media_type}"
    from         DO_NOT_REPLY
    recipients   like.media.user.email
    body         :like => like
  end

  def deny_group(group)
    subject      "Your group request was denied"
    from         DO_NOT_REPLY
    recipients   group.members.first.email
    body         :group => group
  end

  def approve_group(group)
    subject      "Your group request was approved"
    from         DO_NOT_REPLY
    recipients   group.members.first.email
    body         :group => group
  end
  
end
