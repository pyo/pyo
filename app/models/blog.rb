class Blog < ActiveRecord::Base
  is_taggable :tags
  acts_as_rateable
  named_scope :popular,
              :group => "ratings.rateable_id",
              :joins=>:ratings, 
              :order => "avg(score) desc"
  named_scope :recent,
              :order => "created_at desc"
	named_scope :super_user_posts,
							:conditions => {
								:users=>{
									:super_user=>true
								}
							},
							:joins=>:user
  # assocs 
  belongs_to :user
  validates_presence_of :title
  validates_presence_of :body

	after_create :create_activity

	protected
	def create_activity
    user.followers.each do |follower|
      Activity.create({:producer => user, :consumer => follower, :flavor => 'blog', :payload => self})
    end
	end
  
end
