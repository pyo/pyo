require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include Clearance::Test::Unit::UserTest
  should_have_one :profile, :dependent => :destroy
end
