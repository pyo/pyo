class Group < ActiveRecord::Base
  include Covalence::Group
	acts_as_url :name, :sync_url=>true
	
  # assocs 
  has_many :comments, :as => 'consumer', :dependent => :destroy
	has_many :bookings
	has_many :ads
  
  #covalence
  has_members       :users
  has_roles :ADMIN, :MEMBER
  has_default_role  :MEMBER
  has_group_assets_through :user, :tracks #define tracks getter
  
  #scopes
  default_scope :order => 'name', :conditions => {:approved => 1}
  
  #paperclip
  has_attached_file :icon,
                    :styles => { 
                      :medium => "100x100>", 
                      :thumb => "50x50#" 
                    },
                    :whiny_thumbnails => true,
                    :path => ':rails_root/public/data/:class/:id/:style/:basename.:extension',
                    :default_url => '/data/groups/:style.png'
                    
  # validations                  
  validates_presence_of :name, :description
	validates_uniqueness_of :name
      
  def receive_comment_notification comment
    Activity.send_group_comment_notification self, comment
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
  
end
