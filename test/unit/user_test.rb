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
    
    # should "gen the proper following" do
    #   assert_equal FollowingActivity.last.payload, @following
    # end
    # 
    # should "have the correct payload" do
    #   assert_equal FollowingActivity.last.payload.child,@friendee
    # end
    
    # should "assoc the proper activity" do
    #   assert_equal @friender.activities.last, @following
    # end
    
  end
  
  context "A User" do
    setup do
      @user = Factory.create(:user)
    end
    
    should "be able to login by email" do
      assert_not_nil(User.authenticate(@user.email, "testit!"))
    end
    
    should "be able to login by username" do
      assert_not_nil(User.authenticate(@user.name, "testit!"))
    end
  end
  
  context "Creating a New User" do
    setup do
      @user = Factory.create(:user)
    end
    
    should "require a name" do
      assert_makes_invalid(@user) do
        @user.name = nil
      end
    end

    should "not have a name longer than 15 characters" do
      assert_makes_invalid(@user) do
        @user.name = "x" * 16
      end
    end

    should "have a name with only letters, numbers, +,-,_,." do
      assert_makes_invalid(@user) do
        @user.name = "%^gth%!2"
      end
    end
    
    should "have a unique name" do
      new_user = User.new(:name => @user.name)
      assert(!new_user.valid?, "The user has a name that has already been taken")
    end
    
  end
  
end
