class Comment < ActiveRecord::Base
  include Covalence::Notification
  
  #################
  ### Callbacks ###
  #################
  
  after_create :send_notification
  
  def send_notification
    case consumer
    when Photo
      UserMailer.deliver_photo_comment(consumer, self)
    when User
      UserMailer.deliver_user_comment(consumer, self)
    when Track
      UserMailer.deliver_track_comment(consumer, self)
    when Video
      UserMailer.deliver_video_comment(consumer, self)
    when Blog
      UserMailer.deliver_blog_comment(consumer,self)
    end
  end
  
  ####################
  ### Associations ###
  ####################
  
  has_many :comments,   :as => 'consumer', :dependent => :destroy
  has_many :activities, :as => 'payload', :dependent => :destroy
  

  ##############
  ### Scopes ###
  ##############
  
  default_scope :order => "created_at desc"

  ###############
  ### Methods ###
  ###############
  
  def after_create
		unless consumer.is_a?(Comment) || consumer.is_a?(Group)
	    CommentActivity.create({:producer => producer, :payload => self})
	    producer.followers.each do |follower|
	      CommentActivity.create({:producer => producer, :consumer => follower, :payload => self})
	    end
		end
    if consumer.respond_to?(:comments_count)
      consumer.class.increment_counter(:comments_count, consumer.id)
    end
  end
  
  def before_destroy
    if consumer.respond_to?(:comments_count)
      consumer.class.decrement_counter(:comments_count, consumer.id)
    end
  end
end
