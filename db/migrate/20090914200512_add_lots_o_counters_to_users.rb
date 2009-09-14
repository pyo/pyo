class AddLotsOCountersToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :videos_count, :integer, :default => 0                    
    add_column :users, :tracks_count, :integer, :default => 0                    
    add_column :users, :photos_count, :integer, :default => 0                    
    add_column :users, :likes_count, :integer, :default => 0                    
  end
  
  def self.down
    remove_column :users, :likes_count
    remove_column :users, :photos_count
    remove_column :users, :tracks_count
    remove_column :users, :videos_count
  end
end

