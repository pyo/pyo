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
	named_scope :current, :conditions=>"end_date >= NOW()"
	named_scope :expired, :conditions=>"end_date < NOW()"
	
	after_create :create_activity
	
	validates_presence_of :title, :description, :start_date, :end_date, :user_id
	
	def validate
		errors.add_to_base "You cannot change the dates of an event please create a new event" if !new_record? && changed? && (changes["start_date"] || changes["end_date"])
	end
	
	def self.do_search params
		term = params[:q] || ""
		
		search(term, options_from_params(params)).compact
	end
	
	define_index do
		
		indexes title
		indexes description
		has created_at
		has "end_date >= NOW()", :as=>:current, :type=>:boolean
		has ratings.score, :as=>:score
		has "AVG(ratings.score)", :as=>:rating, :type=>:float
		indexes tags(:name), :as => :tags
		
	end
	
	protected
	
	def self.get_order order
		case order.to_sym
		when :most_popular
			"rating DESC"
		when :least_popular
			"rating ASC"
		else
			"created_at DESC"
		end
	end
	
	def self.options_from_params params
		
		params.reverse_merge!({
			:current => true
		})
		
		conditionals = [:tags,:current]
		
		{
			:conditions			=> Hash[*params.select{|k,v|conditionals.include?(k.to_sym)}.flatten],
			:per_page				=> params[:per_page] || 4,
			:page						=> params[:page] || 1,
			:order					=> get_order(params[:order] || :recent),
			:field_weights	=> {:title=>20, :tags=>10, :description=>5}
		}
	end
	
	def create_activity
    user.followers.each do |follower|
      Activity.create({:producer => user, :consumer => follower, :flavor => "event_#{type.downcase}", :payload => self})
    end
  end
	
end
