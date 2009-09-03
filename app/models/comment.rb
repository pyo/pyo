class Comment < ActiveRecord::Base
  include Covalence::Notification
  
  # assocs
  has_many :comments,   :as => 'consumer', :dependent => :destroy
  has_many :activities, :as => 'payload', :dependent => :destroy
  
  #scopes
  default_scope :order => "created_at desc"
  
  def after_create
    producer.followers.each do |follower|
      CommentActivity.create({:producer => producer, :consumer => follower, :payload => self})
    end
    if consumer.respond_to?(:comments_count)
      consumer.class.increment_counter(:comments_count, consumer.id)
    end
  end
  
  def before_destroy
    if consumer.respond_to?(:comments_count)
      consumer.class.decrement_counter(:comments_count, consumer.id)
    end
  end
end
