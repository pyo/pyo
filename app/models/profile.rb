class Profile < ActiveRecord::Base
  # vaildations
  validates_presence_of :first_name,  :message => "can't be blank"
  validates_presence_of :last_name,   :message => "can't be blank"
  validates_presence_of :username,    :message => "can't be blank"
  validates_presence_of :city,        :message => "can't be blank"
  validates_presence_of :state,       :message => "can't be blank"
  validates_presence_of :zip,         :message => "can't be blank"
  
  # assocs
  belongs_to :user
end
