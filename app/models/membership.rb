class Membership < ActiveRecord::Base
  include Covalence::Membership
  def after_create
    if parent.approved?
      Activity.send_join_group_notifications child, parent
      Group.increment_counter(:membership_count, parent.id)
    end
  end

  def before_destroy
    Group.decrement_counter(:membership_count, parent.id)
  end
end
