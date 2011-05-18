class Group < ActiveRecord::Base
  include Covalence::Group
  has_members :users
  has_roles :ADMIN, :MEMBER
  has_default_role :MEMBER
end