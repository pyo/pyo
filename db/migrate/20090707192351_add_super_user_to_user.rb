class AddSuperUserToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :super_user, :boolean, :default => false 
    add_index  :users, :super_user
  end

  def self.down
    remove_column :users, :super_user
  end
end
