class Video < ActiveRecord::Base
	
  is_taggable :tags
  acts_as_rateable

	validates_presence_of :title, :description

  belongs_to :user, :counter_cache => true
  has_many :comments, :as => 'consumer', :dependent => :destroy

  named_scope :finished, :conditions => {:finished => true}
  # default_scope :conditions => {:finished => true}
	named_scope :recent, :order=>"created_at DESC"
  
  def self.unfinished(type, options = {})
    conditions = {:finished => false}.merge(options[:conditions])
    with_exclusive_scope do
      find(type, :conditions => conditions)
    end
  end
  
  def update_panda_status(panda_video)
    RAILS_DEFAULT_LOGGER.info(panda_video)
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
  
  def after_create
    MediaUploadActivity.create({:producer => user, :payload => self})
    user.followers.each do |follower|
      MediaUploadActivity.create({:producer => user, :consumer => follower, :payload => self})
    end
  end
  
  define_index do
      indexes title
      indexes tags(:name)
      indexes description
      indexes [user.profile.first_name, user.profile.last_name, user.name], :as => :user
      indexes user.email, :as => :email
			has created_at
    end
end
