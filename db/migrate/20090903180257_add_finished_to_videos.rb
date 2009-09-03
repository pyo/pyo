class AddFinishedToVideos < ActiveRecord::Migration
  def self.up
    add_column :videos, :finished, :boolean, :default => false        
  end
  
  def self.down
    remove_column :videos, :finished
  end
end

