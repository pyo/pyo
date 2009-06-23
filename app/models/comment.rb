class Comment < ActiveRecord::Base
  include Covalence::Notification
end
