class Photo < ActiveRecord::Base
  is_taggable :tags
  acts_as_rateable
  
  # scopes
  named_scope :recent,
              :order => "photos.created_at DESC"
  named_scope :popular,
              :group => "ratings.rateable_id",
              :joins=>:ratings, 
              :order => "avg(score) desc"
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
                    :bucket => "pyo-images-#{RAILS_ENV}",
                    :default_url => "/images/:attachment/:style/missing.png"
  
  # assocs
  belongs_to :user
  has_many :comments, :as => 'consumer', :dependent => :destroy
  has_many :activities, :as => :payload, :dependent => :destroy 
  
  # validations
  validates_presence_of :title
  validates_presence_of :image_file_name
  
  # covalence hooks
  def receive_comment_notification(notification)
    CommentActivity.create({:producer => notification.producer, :consumer => self})
  end
  
  def after_create
    
    user.followers.each do |follower|
      MediaUploadActivity.create({:producer => user, :consumer => follower, :payload => self})
    end
  end
  
  define_index do
     indexes title
     indexes tags(:name)
     indexes [user.profile.first_name, user.profile.last_name, user.name], :as => :user
     indexes user.email, :as => :email
		has created_at
   end
  
end
