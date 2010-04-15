class Following < ActiveRecord::Base
  include Covalence::Relationship
  
  after_create :send_new_follower_email
  
  def send_new_follower_email
    UserMailer.deliver_new_follower(self)
  end
  
  def after_create
    Alert.create(:producer => parent, :consumer => child, :flavor => 'following')
    
    FollowingActivity.create({:producer => child, :payload => self})
    
    parent.followers+[child].each do |follower|
      FollowingActivity.create({:producer => parent, :consumer => follower, :payload => self})
    end
		
		User.increment_counter(:followers_count, child.id)
		
  end

	def before_destroy
		User.decrement_counter(:followers_count, child.id)
	end

end
