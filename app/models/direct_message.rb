class DirectMessage < ActiveRecord::Base
  include Covalence::Notification
end