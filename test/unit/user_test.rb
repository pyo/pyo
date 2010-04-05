require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # include Clearance::Test::Unit::UserTest
  should_have_one :profile, :dependent => :destroy
	should_have_many :events, :dependent => :destroy
	should_have_many :bookings, :dependent => :destroy
	should_have_many :ads, :dependent => :destroy
  
  context "A User Instance" do
    setup do
      
      @user         = Factory(:user)
      @profile      = Factory(:profile)
      @user.profile = @profile
			@user.save
			
			@friender   = @user
		  @friendee   = Factory.next(:user)
		  @following  = Following.create(:parent =>  @friender, :child =>  @friendee)
    end


    
    should "be able to friend another" do
      assert @friender.followings.include?(@friendee)
    end   
    
    should "gen the proper following" do
      assert_equal FollowingActivity.last.payload, @following
    end
    
    should "have the correct payload" do
      assert_equal FollowingActivity.last.payload.child,@friendee
    end
    
    # should "assoc the proper activity" do
    #   assert_equal @friender.activities.last, @following
    # end
		
  end
  
  
end
