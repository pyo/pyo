require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase
  should_have_db_column :name
  should_have_db_column :description
end
