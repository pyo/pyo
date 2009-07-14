require 'test_helper'

class AdTest < ActiveSupport::TestCase

	test "is a type of ad" do
		ad = Factory.create(:ad)
		assert_match ad.type, "Ad"
	end
	
	should_validate_presence_of :title, :message=>"can't be blank"
	should_validate_presence_of :description, :message=>"can't be blank"
	should_validate_presence_of :user_id, :message=>"can't be blank"
	should_have_many :comments
	
	context "with valid attributes" do
		
		setup do
			
			@valid_attributes = {
			  :title => 'MyString',
			  :description => "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
			  :user_id => '1'
			}
			
		end
		
		should "create an ad" do
			Ad.create!(@valid_attributes)
		end
		
		should "create an ad with a start_date" do
			before = Time.now
			ad = Ad.create!(@valid_attributes)
			assert ad.start_date > before
			assert ad.start_date < Time.now
		end
		
		should "create an ad with a end_date" do
			before = Time.now
			ad = Ad.create!(@valid_attributes)
			after = ad.created_at + Ad::DURATION
			assert (before..after).include?(ad.end_date)
		end
		
	end
	
end
