class Photo < ActiveRecord::Base
  is_taggable :tags
  
  # assocs
  belongs_to :user
  
  # validations
  validates_presence_of :title
  validates_presence_of :image_file_name
  
end
