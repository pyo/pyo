class Comment < ActiveRecord::Base
  include Covalence::Notification
  
  # assocs
  has_many :comments,   :as => 'consumer', :dependent => :destroy
  has_many :activities, :as => 'payload', :dependent => :destroy
  
  def after_create
    producer.followers.each do |follower|
      CommentActivity.create({:producer => producer, :consumer => follower, :payload => self})
    end
  end
end
