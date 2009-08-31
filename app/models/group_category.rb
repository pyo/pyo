class GroupCategory < ActiveRecord::Base
  has_many :groups
  default_scope :order => "name asc"
end
