class AddFollowersCountToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :followers_count, :integer, :default=>0        
    add_index :users, :followers_count
  end
  
  def self.down
    remove_column :users, :followers_count
  end
end

