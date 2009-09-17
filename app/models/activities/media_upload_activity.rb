class MediaUploadActivity < Activity
  default_scope :order => "created_at desc"
  def to_json(options = {})
    {:id => id, :message => message, :user => producer.profile.username, :created_at => ActionView::Base.new.time_ago_in_words(created_at)}.to_json
  end
  
  def media_type
    case payload_type
    when 'Blog' then 'blog entry'
    when 'Track' then 'audio track'
    else payload.type.to_s.singularize.downcase
    end
  end
  
  def icon
    case payload_type
    when 'Video' then 'icons/videos_16-plus.png'
    when 'Track' then 'icons/audio_16-plus.png'
    when 'Photo' then 'icons/photo_16-plus.png'
    when 'Blog' then 'icons/blog_16-plus.png'
    end
  end
end