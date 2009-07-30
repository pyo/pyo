class RemoveAdminFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :admin
  end

  def self.down
    add_column :users, :admin, :boolean, :default=>false
    add_index :users, :admin
  end
end
