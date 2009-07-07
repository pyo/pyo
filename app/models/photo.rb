class Photo < ActiveRecord::Base
  is_taggable :tags
  acts_as_rateable
  
  # scopes
  named_scope :recent,
              :order => "photos.created_at DESC"
  #paperclip
  has_attached_file :image,
                    :styles => { 
                      :thumb => "150x150#", 
                      :medium => "600>" 
                    },
                    :whiny_thumbnails => true,
                    :path => ':rails_root/public/data/:class/:id/:style/:basename.:extension',
                    :url => '/data/:class/:id/:style/:basename.:extension',
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :path => ":attachment/:id/:style.:extension",
                    :bucket => 'pyo-images'
  
  # assocs
  belongs_to :user
  has_many :comments, :as => 'consumer', :dependent => :destroy
  has_many :activities, :as => :payload, :dependent => :destroy 
  
  # validations
  validates_presence_of :title
  validates_presence_of :image_file_name
  
  # covalence hooks
  def receive_comment_notification(notification)
    Activity.create({:producer => notification.producer, :consumer => self, :flavor => 'comment'})
  end
  
  def after_save
    user.followers.each do |follower|
      Activity.create({:producer => user, :consumer => follower, :flavor => 'photo', :payload => self})
    end
  end
  
end
