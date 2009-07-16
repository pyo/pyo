class Following < ActiveRecord::Base
  include Covalence::Relationship
  
  def async_after_create
    Alert.create(:producer => parent, :consumer => child, :flavor => 'following')
    
    parent.followers+[child].each do |follower|
      Activity.create({:producer => parent, :consumer => follower, :flavor => "following", :payload => self})
    end
    
  end
end
