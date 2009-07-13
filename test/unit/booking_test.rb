require 'test_helper'

class BookingTest < ActiveSupport::TestCase

	test "is a type of booking" do
		booking = Factory.create(:booking)
		assert_match booking.type, "Booking"
	end
	
	should_validate_presence_of :title
	should_validate_presence_of :description
	should_validate_presence_of :start_date
	should_validate_presence_of :end_date
	should_validate_presence_of :user_id
	
	context "with valid attributes" do
		
		setup do
			
			@valid_attributes = {
			  :title => 'MyString',
			  :description => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
			  :start_date => '2009-07-13 15:58:36',
			  :end_date => '2009-07-15 15:58:36',
			  :user_id => '1'
			}
			
		end
		
		should "create a booking" do
			Booking.create!(@valid_attributes)
		end
		
	end

end
