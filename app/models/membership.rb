class Membership < ActiveRecord::Base
  include Covalence::Membership
  def after_create
    Activity.send_join_group_notifications child, parent
  end
end
