ROOT = File.dirname(__FILE__)

# Requires
%w{rubygems test/unit active_record shoulda stringio}.each {|dependency| require dependency }
require ROOT + '/../lib/covalence'
%w{group user membership}.each { |model| require "models/#{model}" }

module Kernel
  def capture_output
    out = StringIO.new
    $stdout = out
    yield
    return out
  ensure
    $stdout = STDOUT
  end
end

# Setup ActiveRecord, Load schema
ActiveRecord::Base.establish_connection(YAML::load_file(ROOT + '/database.yml')['sqlite3'])
capture_output { load(ROOT + '/schema.rb') }


# Tests
class UserTest < Test::Unit::TestCase
  
  context "When a user joins a group they" do
    setup do
      @user   = User.create
      @user2  = User.create
      @group  = Group.create
      @role   = :ADMIN
      
      @group.users << @user
      @group.users.join(@user2, @role)
    end
    
    should "be a member of that group" do
      assert_contains @group.users, @user
    end
    
    should "know it's a member of that group" do
      assert @user.member_in?(@group)
    end
    
    should "have the default role if no role was specified" do
      assert_equal @user.role_in(@group), @group.class.default_role.to_s
    end
    
    should "have the specified role" do
      assert_equal @role.to_s, @user2.role_in(@group)
    end
    
    should "be able to change roles" do
      @user.set_role(@group, :ADMIN)
      assert_equal :ADMIN.to_s, @user.role_in(@group)
    end
    
    should "be able to leave that group" do
      @group.users.remove(@user2)
      assert_does_not_contain @group.users, @user2
    end
  end
  
end