class AddTotalViewCountToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :total_view_count, :integer, :default => 0        
  end
  
  def self.down
    remove_column :profiles, :total_view_count
  end
end

