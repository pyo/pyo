class Video < ActiveRecord::Base
	
  is_taggable :tags
  acts_as_rateable

	validates_presence_of :title

  belongs_to :user
  has_many :comments, :as => 'consumer', :dependent => :destroy

	named_scope :recent, :order=>"created_at DESC"
  
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

	def thumb_url
		"#{self.url}_thumb.jpg"
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
