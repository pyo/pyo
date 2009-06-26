class Activity < ActiveRecord::Base
  include Covalence::Notification
  belongs_to :payload, :polymorphic => true
end
