class Comment < ActiveRecord::Base
  include Covalence::Notification
  
  # assocs
  has_many :comments,   :as => 'consumer', :dependent => :destroy
  has_many :activities, :as => 'payload', :dependent => :destroy
  
  def async_after_create
    producer.followers.each do |follower|
      Activity.create({:producer => producer, :consumer => follower, :flavor => "#{self.consumer.class.to_s.underscore}_comment", :payload => self})
    end
  end
end
