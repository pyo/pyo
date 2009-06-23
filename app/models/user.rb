class User < ActiveRecord::Base
  include Covalence::Member
  include Clearance::App::Models::User
  has_one :profile, :dependent => :destroy
  
  has_many :followers, :as => 'child', :class_name => 'Following'
  has_many :followings, :as => 'parent', :class_name => 'Following'
  
  has_many :alerts, :as => 'consumer', :conditions => {:state => 'new'}
  
  validates_presence_of :name
  attr_accessible :email, :password, :password_confirmation, :name
  #covalence
  is_member_of :groups
  
  def to_param
    name
  end
  
  def following?(user)
    followings.exists?(["child_type = ? and child_id = ?", user.class.to_s, user.id])
  end
end