class UserMailer < ActionMailer::Base
  
  def direct_message(direct_message)  
    subject      "You have a new Direct Message from #{direct_message.producer.name} on Put Yourself On..."  
    from         direct_message.producer.name  
    recipients   direct_message.consumer.email  
    body         :direct_message => direct_message
  end
  
  def new_follower(following)
    subject    "#{following.parent.name} is now following you on Put Yourself On!"
    from       DO_NOT_REPLY
    recipients following.child.email
    body       :following => following
  end

  def photo_comment(photo, comment)
    subject      "#{comment.producer.name} posted a comment to your photo on Put Yourself On..."
    from         DO_NOT_REPLY
    recipients   photo.user.email
    body         :photo   => photo,
                 :comment => comment
  end

  def user_comment(user, comment)
    subject      "#{comment.producer.name} posted a comment to your profile on Put Yourself On..."
    from         DO_NOT_REPLY
    recipients   user.email
    body         :user    => user,
                 :comment => comment
  end

  def track_comment(track, comment)
    subject      "#{comment.producer.name} posted a comment to your song on Put Yourself On..."
    from         DO_NOT_REPLY
    recipients   track.user.email
    body         :track    => track,
                 :comment => comment
  end

  def video_comment(video, comment)
    subject      "#{comment.producer.name} posted a comment to your video on Put Yourself On..."
    from         DO_NOT_REPLY
    recipients   video.user.email
    body         :video   => video,
                 :comment => comment
  end

  def blog_comment(blog, comment)
    subject      "#{comment.producer.name} posted a comment to your blog on Put Yourself On..."
    from         DO_NOT_REPLY
    recipients   blog.user.email
    body         :blog    => blog,
                 :comment => comment
  end

  def like_email(like)
    subject      "The user #{like.user.name} likes your #{like.media_type}!"
    from         DO_NOT_REPLY
    recipients   like.media.user.email
    body         :like => like
  end

  def deny_group(group)
    subject      "Your group request for #{group.name} was denied..."
    from         DO_NOT_REPLY
    recipients   group.members.first.email
    body         :group => group
  end

  def approve_group(group)
    subject      "Your group request #{group.name} was approved!"
    from         DO_NOT_REPLY
    recipients   group.members.first.email
    body         :group => group
  end
  
end
