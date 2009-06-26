class User < ActiveRecord::Base
  include Covalence::Member
  include Clearance::App::Models::User
  attr_accessible :email, :password, :password_confirmation, :name, :profile_attributes

  # assocs
  has_one  :profile, :dependent => :destroy
  has_many :photos
  has_many :tracks
  
  has_many :parents, :as => 'child', :class_name => 'Following'
  has_many :followers, :through => :parents, :source => "parent", :source_type => "User"


  has_many :children, :as => 'parent', :class_name => 'Following'
  has_many :followings, :through => :children, :source => "child", :source_type => "User"
  
  has_many :alerts, :as => 'consumer', :conditions => {:state => 'new'}
  has_many :comments, :as => 'consumer'
  has_many :activities, :as => 'consumer'
  
  # validations
  validates_presence_of :name
  validates_uniqueness_of :name
  
  accepts_nested_attributes_for :profile, :allow_destroy => true
  
  # covalence
  is_member_of :groups
  
  def following?(user)
    followings.exists?(["child_type = ? and child_id = ?", user.class.to_s, user.id])
  end
  
  def receive_comment_notification(notification)
    Activity.create({:producer => notification.producer, :consumer => self, :flavor => 'comment'})
  end
  
  def to_param
    name
  end

end