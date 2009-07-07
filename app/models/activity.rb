class Activity < ActiveRecord::Base
  include Covalence::Notification
  belongs_to :payload, :polymorphic => true
  
  def self.send_join_group_notifications user, group
    user.followers.each do |follower|
      Activity.create({:producer => user, :consumer => follower, :flavor => 'join_group', :payload => group})
    end
  end
  
end
