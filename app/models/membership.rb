class Membership < ActiveRecord::Base
  include Covalence::Membership
  def after_create
    if parent.approved?
      Activity.send_join_group_notifications child, parent
    end
  end
end
