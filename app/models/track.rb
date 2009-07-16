class Track < ActiveRecord::Base
  is_taggable :tags
  acts_as_rateable
  
  # scopes
  named_scope :recent,
              :order => "tracks.created_at DESC"
  named_scope :popular,
              :group => "ratings.rateable_id",
              :joins=>:ratings, 
              :order => "avg(score) desc"
              
              
  #paperclip
  has_attached_file :mp3,
                    :path => ':rails_root/public/data/:class/:id/:style/:basename.:extension',
                    :url => '/data/:class/:id/:style/:basename.:extension',
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :path => ":attachment/:id/:style.:extension",
                    :bucket => "pyo-tracks-#{RAILS_ENV}"
  #assocs 
  belongs_to  :user
  has_many    :activities, :as => :payload, :dependent => :destroy 
  has_many    :comments, :as => 'consumer'
  
  # validations
  validates_presence_of             :name
  validates_presence_of             :user_id
  #validates_attachment_presence     :mp3
  #validates_attachment_content_type :mp3, "audio/mpeg"
  
  
  # covalence hooks
  def receive_comment_notification(notification)
    Activity.create({:producer => notification.producer, :consumer => self, :flavor => 'comment'})
  end
  
  def async_after_create
    user.followers.each do |follower|
      Activity.create({:producer => user, :consumer => follower, :flavor => 'track', :payload => self})
    end
  end
  
end
