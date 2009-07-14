class Booking < Event
  has_many    :comments, :dependent => :destroy, :conditions=>"comments.consumer_type = 'Booking'", :foreign_key=>'consumer_id'
end
