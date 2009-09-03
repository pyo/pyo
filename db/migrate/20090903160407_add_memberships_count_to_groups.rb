class AddMembershipsCountToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :memberships_count, :integer, :default => 0        
  end
  
  def self.down
    remove_column :groups, :memberships_count
  end
end

