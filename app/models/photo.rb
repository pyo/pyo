class Photo < ActiveRecord::Base
  has_attached_file :image,
                    :styles => { 
                      :thumb => "x150>", 
                      :medium => "600>" 
                    },
                    :whiny_thumbnails => true,
                    :path => ':rails_root/public/data/:class/:id/:style/:basename.:extension',
                    :url => '/data/:class/:id/:style/:basename.:extension',
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :path => ":attachment/:id/:style.:extension",
                    :bucket => 'pyo-images'
  is_taggable :tags
  
  # assocs
  belongs_to :user
  
  # validations
  validates_presence_of :title
  validates_presence_of :image_file_name
  
end
