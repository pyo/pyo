class Event < ActiveRecord::Base
	
  is_taggable :tags
  acts_as_rateable
  
  named_scope :popular,
              :group => "ratings.rateable_id",
              :joins=>:ratings, 
              :order => "avg(score) desc"
	
	belongs_to :user
	belongs_to :group
	
	named_scope :recent, :order=>"`events`.created_at DESC"
	
	validates_presence_of :title, :description, :start_date, :end_date, :user_id
	
	def validate
		errors.add_to_base "You cannot change the dates of an event please create a new event" if !new_record? && changed? && (changes["start_date"] || changes["end_date"])
	end
	
end
