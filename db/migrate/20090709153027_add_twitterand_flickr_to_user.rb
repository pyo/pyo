class AddTwitterandFlickrToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :twitter_username, :string
    add_column :users, :twitter_password, :string
    add_column :users, :flickr_username, :string
    
  end

  def self.down
    remove_column :users, :flickr_username
    remove_column :users, :twitter_password
    remove_column :users, :twitter_username
  end
end
