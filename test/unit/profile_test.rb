require File.dirname(__FILE__) + '/../test_helper'

class ProfileTest < ActiveSupport::TestCase
  should_have_db_column :first_name
  should_have_db_column :last_name
  should_have_db_column :username
  should_have_db_column :address
  should_have_db_column :city
  should_have_db_column :state
  should_have_db_column :zip
  should_have_db_column :twitter
  should_have_db_column :youtube
  should_have_db_column :flickr
  should_have_db_column :bio
  
  should_belong_to :user
  
  should_validate_presence_of :first_name, :last_name, :username, :city, :state, :zip
end
