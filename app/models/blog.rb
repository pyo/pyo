class Blog < ActiveRecord::Base
  is_taggable :tags
  acts_as_rateable
  
  # assocs 
  belongs_to :user
  validates_presence_of :title
  validates_presence_of :body
end
