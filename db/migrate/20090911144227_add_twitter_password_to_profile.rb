class AddTwitterPasswordToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :twitter_password, :string
    add_index  :profiles, :twitter_password
  end

  def self.down
    remove_column :profiles, :twitter_password
  end
end
