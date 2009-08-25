class AddUrlToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :url, :string        
  end
  
  def self.down
    remove_column :profiles, :url
  end
end

