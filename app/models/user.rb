class User < ActiveRecord::Base
  
  TALENT_TYPES	= %w{DJ Producer Singer Guitarist Drummer Fan}.sort
	SORT_TYPES			= {
		:most_followers=>"`users`.followers_count DESC, `profiles`.last_name ASC",
		:least_followers=>"`users`.followers_count ASC, `profiles`.last_name ASC",
		:newest=>"`users`.created_at DESC",
		:oldest=>"`users`.created_at ASC",
		:alphabetical=>"`users`.name ASC"
	}
	
  validates_presence_of :password, :message=>"You must enter a password", :on => :create
  validates_presence_of :email, :message=>"You must enter an email"
  validates_format_of   :name, :with => /^[-a-z0-9_.+]+$/i, :message => "Usernames can only contain letters, numbers, underscores, periods, pluses and dashes"
  
  include Covalence::Member
  include Clearance::App::Models::User
  attr_accessible :email, :password, :password_confirmation, :name, :profile_attributes, :tag_list, :talent_type, :twitter_username, :twitter_password, :flickr_username, :flickr_id, :industry
  is_taggable :tags
	acts_as_url :name, :sync_url=>true

  
  # assocs
  has_one  :profile, :dependent => :destroy
  has_many :photos, :dependent => :destroy
  has_many :tracks, :dependent => :destroy
  has_many :videos, :dependent => :destroy, :conditions => ["`videos`.finished = ?", true]
  has_many :activities, :as => :payload, :dependent => :destroy
	has_many :events, :dependent=>:destroy
	has_many :bookings, :dependent=>:destroy
	has_many :ads, :dependent=>:destroy
	has_many :blogs
	has_many :likes
  
  # setup followers
  has_many :_followings,    :as => 'child', :class_name => 'Following'
  has_many :followers, :through => :_followings, :source => "parent", :source_type => "User" do
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
  has_many :new_messages, :as => :consumer, :class_name => 'DirectMessage', :conditions => {:state => 'new'}
  has_many :new_followings, :as => :consumer, :class_name => 'FollowingActivity', :conditions => {:state => 'new'}
  has_many :new_comments, :as => :consumer, :class_name => 'CommentActivity', :conditions => {:state => 'new'}
  has_many :sent_messages, :as => :producer, :class_name => 'DirectMessage'

  has_many :updates, :class_name => "Activity", :as => :producer, :conditions => {:consumer_id => nil}
  has_many :profile_updates, :class_name => "Activity", :as => :producer, :conditions => ["consumer_id is NULL and type != 'FollowingActivity'"]

	named_scope :featured, :conditions=>{ :featured => true }
	named_scope :sort_by, lambda{|*args| {:order=>User::SORT_TYPES[(args.first || "newest").to_sym], :joins=>[:profile]} }
  
  # covalence groups
  is_member_of :groups
  
  # validations
  validates_presence_of   :name, :message =>"You must enter a username"
  validates_uniqueness_of :name, :message => "has already been taken.  Please choose a different username.", :case_sensitive => false
  validates_length_of     :name, :maximum => 15
  validates_presence_of   :talent_type, :message=>"This field is required so that we can place you in the correct classification on PYO. Please try to name your talent as accurately and appropriately as possible. If you don’t have a talent, and are looking to use PYO to simply discover and promote the talent already here, you can simply classify yourself as a \"Fan\"."
  validates_presence_of   :tag_list, :message => "This field is required so that we can properly group you within the correct industries on PYO. For example, if you chose “Athlete” as your talent type, you would include the sport(s) you play, like \"basketball\", \"football\", \"soccer\", \"track\", etc. If you can’t think of any tags at the moment, just put whatever you put in the \"Talent Type\" field there. You can always change this later."
  
  accepts_nested_attributes_for :profile, :allow_destroy => true
  
  def self.authenticate(email, password)
    return nil  unless user = find_by_email_and_suspended(email, false) || 
                              find_by_name_and_suspended(email, false)
    return user if     user.authenticated?(password)
  end
    
  def all_activities
    Activity.all(:conditions => [
      "(consumer_type = 'User' and consumer_id = ?) or (producer_type = 'User' and producer_id in (?))", 
      id,
      followings.map(&:id)
    ],
    :order => 'created_at desc')
  end
  
  def following?(user)
    followings.exists?(["child_type = ? and child_id = ?", user.class.to_s, user.id])
  end
  
  acts_as_flickr_user :flickr_nsid => 'flickr_id' # defaults :flickr_username => 'flickr_username'
  
  def owns?(resource)
    methods = %w{user producer}
    resource_user_method = methods.select{|method| resource.respond_to?(method)}[0]
    if resource_user_method
      super_user? || resource.send(resource_user_method) == self
    end
  end
  
  def likes?(resource)
    RAILS_DEFAULT_LOGGER.info(resource.class.to_s)
    likes.exists?(:media_type => resource.class.to_s, :media_id => resource.id)
  end
  
  def tweets        
    unless profile.twitter == "" || profile.twitter_password == ""
      twitter = Twitter.new(profile.twitter,profile.twitter_password) 
      tweets  = twitter.timeline(:user,:query=>{:count=>8})            
      if tweets.class != Hash
        tweets
      else
        []
      end
    else
      []
    end
  end
  
  def status
    updates.first(:conditions => {:type => 'StatusActivity'})
  end
  
  def connects_size
    # divide by 2 because it returns the user on both sides of the relationship and we can't do distinct on the count
    User.count(
      :joins => %{
        join followings as ls
        on
        (ls.parent_id = '#{id}' and users.id = ls.child_id)
        or
        (ls.child_id = '#{id}' and users.id = ls.parent_id)
        join followings as rs
        on
        (rs.parent_id = '#{id}' and rs.child_id = ls.parent_id and ls.child_id = '#{id}')
        or
        (rs.child_id = '#{id}' and rs.parent_id = ls.child_id and ls.parent_id = '#{id}')
      }
    ) / 2
  end
  
  def self.find_by_id_and_token(id, token) #override clearance
    self.find_by_name_and_token(id, token)
  end
  
  def city_and_state
    returning [] do |values|
      values << profile.city if profile.city.present?
      values << profile.state if profile.state.present?
    end
  end

	def to_param
		url
	end

  define_index do
    indexes name
    indexes [profile.first_name, profile.last_name], :as => :full_name
    indexes email
    indexes [profile.city, profile.state], :as => :location
		has profile.created_at, :as => :created_at
  end

end