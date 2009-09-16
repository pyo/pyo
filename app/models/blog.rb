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
  
  
  define_index do
     indexes title
     indexes tags(:name)
     indexes body
     indexes [user.profile.first_name, user.profile.last_name, user.name], :as => :user
     indexes user.email, :as => :email
		has created_at
   end

	protected
	def create_activity
	  MediaUploadActivity.create({:producer => user, :payload => self})
    user.followers.each do |follower|
      MediaUploadActivity.create({:producer => user, :consumer => follower, :payload => self})
    end
	end
  
end
