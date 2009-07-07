class AddApprovedToGroup < ActiveRecord::Migration
  def self.up
    add_column  :groups, :approved, :boolean, :default => false
    add_index   :groups, :approved 
  end

  def self.down
    remove_column :groups, :approved
  end
end
