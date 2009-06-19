class User < ActiveRecord::Base
  include Covalence::Groupable
  include Clearance::App::Models::User
  has_one :profile, :dependent => :destroy
  
  #covalence
  is_member_of :groups
end