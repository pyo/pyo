class AddFirstRunToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :first_run, :boolean, :default => true 
    add_index  :users, :first_run
  end

  def self.down
    remove_column :users, :first_run
  end
end
