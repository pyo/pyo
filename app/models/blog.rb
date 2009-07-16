class Blog < ActiveRecord::Base
  is_taggable :tags
  acts_as_rateable
  named_scope :popular,
              :group => "ratings.rateable_id",
              :joins=>:ratings, 
              :order => "avg(score)"
  # assocs 
  belongs_to :user
  validates_presence_of :title
  validates_presence_of :body
end
