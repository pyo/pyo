class Like < ActiveRecord::Base
  
  #################
  ### Callbacks ###
  #################
  
  after_create :send_like_email
  
  def send_like_email
    UserMailer.deliver_like_email(self)
  end
  
  ####################
  ### Associations ###
  ####################
  
  belongs_to :user, :counter_cache => true
  belongs_to :media, :polymorphic => true
  
  default_scope :order => "created_at DESC"
  
  ###############
  ### Methods ###
  ###############
  
  def media_image_url
    case media_type
    when 'Video' then media.thumb_url
    when 'Photo' then media.image.url(:thumb)
    when 'Track' then nil
    end
  end
  
  def media_title
    media.respond_to?(:title) ? media.title : media.name
  end
  
  
  def after_create
    LikeActivity.create(:producer => user, :payload => media)
    ([media.user] | user.followers).each do |follower|
      LikeActivity.create(:producer => user, :consumer => follower, :payload => media)
    end
  end
end
