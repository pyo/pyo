class AddCommentsCountToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :comments_count, :integer, :default => 0        
  end
  
  def self.down
    remove_column :tracks, :comments_count
  end
end

