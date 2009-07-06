class Comment < ActiveRecord::Base
  include Covalence::Notification
  
  # assocs
  has_many :comments, :as => 'consumer'
  
  def after_save
    producer.followers.each do |follower|
      Activity.create({:producer => producer, :consumer => follower, :flavor => "#{self.consumer.class.to_s.underscore}_comment", :payload => self.consumer})
    end
  end
end
