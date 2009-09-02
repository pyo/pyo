class Following < ActiveRecord::Base
  include Covalence::Relationship
  def after_create
    Alert.create(:producer => parent, :consumer => child, :flavor => 'following')
    
    parent.followers+[child].each do |follower|
      FollowingActivity.create({:producer => parent, :consumer => follower, :payload => self})
    end    
  end
  
end
