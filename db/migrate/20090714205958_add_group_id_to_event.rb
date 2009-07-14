class AddGroupIdToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :group_id, :integer
		add_index :events, :group_id
  end

  def self.down
		remove_index :events, :group_id
    remove_column :events, :group_id
  end
end
