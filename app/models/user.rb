class User < ActiveRecord::Base
  TALENT_TYPES = %w{DJ Producer Singer Guitarist Drummer Fan}.sort
  
  include Covalence::Member
  include Clearance::App::Models::User
  attr_accessible :email, :password, :password_confirmation, :name, :profile_attributes, :tag_list, :talent_type, :twitter_username, :twitter_password, :flickr_username
  is_taggable :tags
  
  # assocs
  has_one  :profile, :dependent => :destroy
  has_many :photos
  has_many :tracks
  has_many :activities, :as => :payload, :dependent => :destroy 
  
  # setup followers
  has_many :parents,    :as => 'child', :class_name => 'Following'
  has_many :followers,  :through => :parents, :source => "parent", :source_type => "User" do
    def recent
      all(:limit=>8,:order => "created_at DESC" )
    end
  end

  # setup followings
  has_many :children,   :as => 'parent', :class_name => 'Following'
  has_many :followings, :through => :children, :source => "child", :source_type => "User" do
    def recent
      all(:limit=>8,:order => "created_at DESC" )
    end
  end
  
  # Covalence notifications
  has_many :alerts,     :as => 'consumer', :conditions => {:state => 'new'}
  has_many :comments,   :as => 'consumer'
  has_many :activities, :as => 'consumer'
  
  has_many :messages, :as => :consumer, :class_name => 'DirectMessage'
  has_many :sent_messages, :as => :producer, :class_name => 'DirectMessage'
  
  # covalence groups
  is_member_of :groups
  
  # validations
  validates_presence_of   :name
  validates_uniqueness_of :name
  
  accepts_nested_attributes_for :profile, :allow_destroy => true
  
  def following?(user)
    followings.exists?(["child_type = ? and child_id = ?", user.class.to_s, user.id])
  end
  
  def receive_comment_notification(notification)
    Activity.create({:producer => notification.producer, :consumer => self, :flavor => 'profile_comment', :payload=>self})
  end
  
  def tweets    
    if twitter_username.nil? && twitter_password.nil?
      twitter = Twitter.new(twitter_username,twitter_password) 
      twitter.timeline(:user,:query=>{:count=>8})
    else
      []
    end
  end
  
  def to_param
    name
  end

end