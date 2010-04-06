require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < ActiveSupport::TestCase
  #   should_have_db_column :first_name
  #   should_have_db_column :last_name
  #   should_have_db_column :username
  #   should_have_db_column :address
  #   should_have_db_column :city
  #   should_have_db_column :state
  #   should_have_db_column :zip
  #   should_have_db_column :twitter
  #   should_have_db_column :youtube
  #   should_have_db_column :flickr
  #   should_have_db_column :bio
  #   
  #   should_belong_to :user
  #   
  #   should_validate_presence_of :first_name, :last_name, :username, :city, :state, :zip
  # 
  # context "A Profile Instance" do
  #   
  #   setup do
  #     @profile = Factory.next(:profile)
  #   end
  #   
  #   should "have a full_name" do
  #     assert_match @profile.full_name, "#{@profile.first_name} #{@profile.last_name}"
  #   end
  #   
  # end

  context "Creating a New Profile" do
    setup do
      @profile = Factory.create(:profile)
    end
    
    should "require a usernamename" do
      assert_makes_invalid(@profile) do
        @profile.username = nil
      end
    end

    should "not have a name longer than 15 characters" do
      assert_makes_invalid(@profile) do
        @profile.username = "x" * 16
      end
    end

    should "have a name with only letters, numbers, +,-,_,." do
      assert_makes_invalid(@profile) do
        @profile.username = "%^gth%!2"
      end
    end
    
    should "have a unique name" do
      new_profile = Profile.new(:username => @profile.username)
      assert(!new_profile.valid?, "The user has a username that has already been taken")
    end
    
  end
  
	
end
