class DirectMessage < ActiveRecord::Base
  include Covalence::Notification
  
  #################
  ### Callbacks ###
  #################
  
  after_create :send_direct_message
  
  def send_direct_message
    UserMailer.deliver_direct_message(self)
  end

  ##############
  ### Scopes ###
  ##############

  named_scope :unread, :conditions => {:state=>"new"}
  named_scope :read,   :conditions => ["state != ?","new"]

  
end