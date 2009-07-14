require 'test_helper'

class EventTest < ActiveSupport::TestCase
	
	should_belong_to :user
	
	context "An Instance" do
		setup do
		
			@valid_attributes = {
				:type					=>'Booking',
			  :title				=> 'MyString',
			  :description	=> "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
			  :start_date		=> '2009-07-13 15:58:36',
			  :end_date			=> '2009-07-15 15:58:36',
			  :user_id			=> '1'
			}
			
		end
	
		should "not be able to update start_date and end_date" do
			event = Event.create!(@valid_attributes)
			event.start_date = Time.now
			event.end_date = Time.now
			assert !event.valid?
		end
		
	end
	
end
