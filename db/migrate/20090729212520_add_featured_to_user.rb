class AddFeaturedToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :featured, :boolean, :default=>false
    add_index :users, :featured
  end

  def self.down
    remove_column :users, :featured
  end
end
