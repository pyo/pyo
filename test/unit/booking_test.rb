require 'test_helper'

class BookingTest < ActiveSupport::TestCase

	test "is a type of booking" do
		booking = Factory.create(:booking)
		assert_match booking.type, "Booking"
	end
	
	should_have_many :comments
	
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
		
		should "have an end date occuring after the start date" do
			@valid_attributes[:start_date] = '2009-07-15 15:58:36'
			@valid_attributes[:end_date] = '2009-07-12 15:58:36'
			booking = Booking.new(@valid_attributes)
			assert !booking.valid?
		end
		
	end
	
	# context "Bookings" do
	# 	
	# 	setup do
	# 		Event.after_create.reject!{|c| [:create_activity].include?(c.method)}
	# 		
	# 		@tags = [Factory.next(:tag),Factory.next(:tag),Factory.next(:tag)]
	# 		@tags.each do |tag|
	# 			booking = Factory.create(:booking)
	# 			booking.tags << tag
	# 		end
	# 		
	# 		puts Booking.all.collect(&:title).inspect
	# 		ActiveSupport::TestCase.ts_rebuild
	# 		
	# 	end
	# 	
	# 	should "search for bookings with tags" do
	# 		tag_to_search = @tags.rand.name
	# 		puts tag_to_search
	# 		bookings = Booking.search_for_ids "My" # :conditions=>{:tags=>"tag"}
	# 		puts bookings.inspect
	# 		puts Booking.all.collect(&:title).inspect
	# 		assert bookings.length > 0
	# 		bookings.each do |booking|
	# 			assert booking.tags.collect(&:name).include?(tag_to_search)
	# 		end
	# 	end
	# 	
	# end

end
