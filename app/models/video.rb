class Video < ActiveRecord::Base
  is_taggable :tags
  belongs_to :user
  
  def update_panda_status(panda_video)
    if encoding = panda_video.find_encoding(PANDA_ENCODING)
      if encoding.status == 'success'
        self.filename = encoding.filename
        self.width = encoding.width
        self.height = encoding.height
        self.save
      end
    end
  end
  
  def url
    "http://#{VIDEOS_DOMAIN}/#{self.filename}"
  end
  
  def screenshot_url
    "#{self.url}.jpg"
  end
  
  def embed_html
    %(<embed src="http://#{VIDEOS_DOMAIN}/player.swf" width="#{self.width}" height="#{self.height}" allowfullscreen="true" allowscriptaccess="always" flashvars="&displayheight=#{self.height}&file=#{self.url}&image=#{self.screenshot_url}&width=#{self.width}&height=#{self.height}" />)
  end
  
  define_index do
      indexes title
      indexes tags(:name)
      indexes description
      indexes [user.profile.first_name, user.profile.last_name, user.name], :as => :user
    end
end