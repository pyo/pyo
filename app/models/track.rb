class Track < ActiveRecord::Base
  is_taggable :tags
  #paperclip
  has_attached_file :mp3,
                    :path => ':rails_root/public/data/:class/:id/:style/:basename.:extension',
                    :url => '/data/:class/:id/:style/:basename.:extension',
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :path => ":attachment/:id/:style.:extension",
                    :bucket => 'pyo-tracks'
  #assocs 
  belongs_to  :user
  has_many    :comments, :as => 'consumer'
  
  # validations
  validates_presence_of             :name
  validates_presence_of             :user_id
  #validates_attachment_presence     :mp3
  #validates_attachment_content_type :mp3, "audio/mpeg"
end
