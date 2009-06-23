class Following < ActiveRecord::Base
  include Covalence::Relationship
  
  def after_create
    Alert.create(:producer => parent, :consumer => child, :flavor => 'following')
  end
end
