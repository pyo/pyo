class Comment < ActiveRecord::Base
  include Covalence::Notification
  
  def after_save
    producer.followers.each do |follower|
      Activity.create({:producer => producer, :consumer => follower, :flavor => "#{self.consumer.class.to_s.underscore}_comment", :payload => self.consumer})
    end
  end
end
