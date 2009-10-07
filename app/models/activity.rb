class Activity < ActiveRecord::Base
  include Covalence::Notification
  belongs_to :payload, :polymorphic => true
  default_scope :order => 'created_at desc'
  def self.send_join_group_notifications user, group
    user.followers.each do |follower|
      JoinGroupActivity.create({:producer => user, :consumer => follower, :payload => group})
    end
  end
  
  def self.send_group_comment_notification group, comment
    group.users.each do |user|
     GroupCommentActivity.create({:producer => comment.producer, :consumer => user, :payload => comment}) if comment.producer != user
    end
  end
end
