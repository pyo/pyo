class User < ActiveRecord::Base
  include Covalence::Member
  include Clearance::App::Models::User
  attr_accessible :email, :password, :password_confirmation, :name

  #assocs
  has_one  :profile, :dependent => :destroy
  has_many :photos
  has_many :followers, :as => 'child', :class_name => 'Following'
  has_many :followings, :as => 'parent', :class_name => 'Following'
  has_many :alerts, :as => 'consumer', :conditions => {:state => 'new'}
  has_many :comments, :as => 'consumer'
  has_many :activities, :as => 'consumer'
  
  # validations
  validates_presence_of :name
  validates_uniqueness_of :name
  
  #covalence
  is_member_of :groups
  
  def to_param
    name
  end
  
  def following?(user)
    followings.exists?(["child_type = ? and child_id = ?", user.class.to_s, user.id])
  end
  
  def receive_comment_notification(notification)
    Activity.create({:producer => notification.producer, :consumer => self, :flavor => 'comment'})
  end
end