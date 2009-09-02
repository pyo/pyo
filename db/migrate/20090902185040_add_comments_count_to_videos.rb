class AddCommentsCountToVideos < ActiveRecord::Migration
  def self.up
    add_column :videos, :comments_count, :integer, :default => 0        
  end
  
  def self.down
    remove_column :videos, :comments_count
  end
end

