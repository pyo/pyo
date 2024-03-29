class Group < ActiveRecord::Base
  include Covalence::Group
  
  SORT_TYPES = {
    :most_members=>"`groups`.memberships_count DESC, `groups`.name ASC",
    :least_members=>"`groups`.memberships_count ASC, `groups`.name ASC",
    :newest=>"`groups`.created_at DESC",
    :oldest=>"`groups`.created_at ASC",
    :alphabetical=>"`groups`.name ASC"
  }
  
	acts_as_url :name, :sync_url=>true
	
  # assocs 
  has_many :comments, :as => 'consumer', :dependent => :destroy
	has_many :bookings
	has_many :ads
	belongs_to :group_category
  
  #covalence
  has_members       :users
  has_roles :ADMIN, :MEMBER
  has_default_role  :MEMBER
  has_group_assets_through :user, :tracks #define tracks getter
  
  has_many :photos, :through => :users
  has_many :videos, :through => :users
  has_many :tracks, :through => :users
  
  #scopes
  default_scope :order => 'name', :conditions => {:approved => 1}
  named_scope :sort_by, lambda{|*args| {:order=>Group::SORT_TYPES[(args.first || "newest").to_sym]} }
  
  #paperclip
  has_attached_file :icon,
                    :styles => { 
                      :medium => "120x120>", 
                      :thumb => "50x50#",
                      :profile => "230x230#"
                    },
                    :whiny_thumbnails => true,
                    :path => ':rails_root/public/data/:class/:id/:style/:basename.:extension',
                    :url => '/data/:class/:id/:style/:basename.:extension',
                    :default_url => '/data/groups/:style.png'
                    
  # validations                  
  validates_presence_of :name, :description, :group_category_id
	validates_uniqueness_of :name
  
  before_create :check_approved
  before_update :check_approved
  before_destroy :check_approved_destroy
  
  def receive_comment_notification comment
    Activity.send_group_comment_notification self, comment
  end

  def with_approved_scope &block
    previously_approved = approved?
    self.update_attribute(:approved, true)
    yield block
    self.update_attribute(:approved, false) unless previously_approved
  end

	def self.new_with_pending attrs
		with_exclusive_scope { new attrs }
	end
	
	def self.create_with_pending attrs
		with_exclusive_scope { new attrs }
	end
  
  def self.pending
    with_exclusive_scope {
      all(:conditions=>{:approved=>false})
    }
  end
  
  def self.find_pending id
    with_exclusive_scope {
				find(id)
    }
  end
  
  def self.find_pending_by_url url
    with_exclusive_scope {
				find_by_url(url)
    }
  end

  def to_param
    url
  end
  
  def check_approved
    if(approved_changed?)
      GroupCategory.send((approved? ? :increment_counter : :decrement_counter), :groups_count, group_category)
    end
  end
  
  def check_approved_destroy
    GroupCategory.decrement_counter(:groups_count, group_category) if(approved)
  end
end
