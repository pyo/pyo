Factory.define :booking do |booking|
  booking.title 'MyString'
  booking.description "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
  booking.start_date '2009-07-13 15:58:36'
  booking.end_date '2009-07-15 15:58:36'
  booking.user_id '1'
end

Factory.sequence :booking do |n|
	
	Factory.create(:booking,{
		:title=>"Event #{n}",
		:start_date=>Time.now + (0..2).to_a.rand.days,
		:end_date => Time.now + (3..10).to_a.rand.days
	})
	
end
