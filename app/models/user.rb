class User < ActiveRecord::Base
  include Covalence::Member
  include Clearance::App::Models::User
  has_one :profile, :dependent => :destroy
  
  validates_presence_of :name
  attr_accessible :email, :password, :password_confirmation, :name
  #covalence
  is_member_of :groups
end