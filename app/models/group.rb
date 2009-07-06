class Group < ActiveRecord::Base
  include Covalence::Group
  #covalence
  has_members       :users
  has_roles :ADMIN, :MEMBER
  has_default_role  :MEMBER
  
  #scopes
  default_scope :order => 'name'
  named_scope :with_role, lambda { |role| { :conditions => ['status = ?', role.to_s] } }
  
  #paperclip
  has_attached_file :icon,
                    :styles => { 
                      :medium => "100x100>", 
                      :thumb => "50x50#" 
                    },
                    :whiny_thumbnails => true,
                    :path => ':rails_root/public/data/:class/:id/:style/:basename.:extension',
                    :url => '/data/:class/:id/:style/:basename.:extension'
end
