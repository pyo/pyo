class DirectMessage < ActiveRecord::Base
  include Covalence::Notification
  #scopes
  named_scope :unread, :conditions => {:state=>"new"}
  named_scope :read,   :conditions => ["state != ?","new"]

  
end