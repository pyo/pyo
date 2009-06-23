class User < ActiveRecord::Base
  include Covalence::Member
  include Clearance::App::Models::User
  attr_accessible :email, :password, :password_confirmation, :name

  #assocs
  has_one :profile, :dependent => :destroy
  has_many :photos
  
  # validations
  validates_presence_of :name
  validates_uniqueness_of :name
  
  #covalence
  is_member_of :groups
end