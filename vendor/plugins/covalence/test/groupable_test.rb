require File.dirname(__FILE__) + '/helper'

class GroupableTest < ActiverecordTest
  context "Membership" do
    setup do
      Fixtures.create_fixtures(FIXTURES_PATH, 'users')
    end
  
    should "have @user as child" do
      user = User.first
      puts user.name
      assert_equal "Thomas", user.name
    end
    
    should "have @group as parent" do
      assert true
    end
  end
end