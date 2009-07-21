class Booking < Event
	
  has_many    :comments, :dependent => :destroy, :conditions=>"comments.consumer_type = 'Booking'", :foreign_key=>'consumer_id'

	def validate
		errors.add_to_base "The end date must be later then the start date" if start_date && end_date && start_date >= end_date
	end
end
