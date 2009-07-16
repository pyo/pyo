class Blog < ActiveRecord::Base
  is_taggable :tags
  acts_as_rateable
  named_scope :popular,
              :group => "ratings.rateable_id",
              :joins=>:ratings, 
              :order => "avg(score) desc"
  # assocs 
  belongs_to :user
  validates_presence_of :title
  validates_presence_of :body
  
  def async_after_create
    user.followers.each do |follower|
      Activity.create({:producer => user, :consumer => follower, :flavor => 'blog', :payload => self})
    end
  end
  
end
