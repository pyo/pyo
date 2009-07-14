require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # include Clearance::Test::Unit::UserTest
  should_have_one :profile, :dependent => :destroy
	should_have_many :events, :dependent => :destroy
	should_have_many :bookings, :dependent => :destroy
	should_have_many :ads, :dependent => :destroy
  
  context "A User Instance" do
    setup do
      @user = Factory(:user)
      @profile = Factory(:profile)
      @user.profile = @profile
			@user.save
    end

    should "have a profile" do
      assert @user.profile == @profile
    end
		
  end
  
  
end
