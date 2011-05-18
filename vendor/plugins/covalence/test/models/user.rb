class User < ActiveRecord::Base
  include Covalence::Member
  is_member_of :groups
end