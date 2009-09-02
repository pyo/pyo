class Like < ActiveRecord::Base
  belongs_to :user
  belongs_to :media, :polymorphic => true
  default_scope :order => "created_at DESC"
  
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
end
