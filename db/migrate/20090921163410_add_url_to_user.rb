class AddUrlToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :url, :string        
    add_index :users, :url
  end
  
  def self.down
    remove_column :users, :url
  end
end

