class AddTimezoneToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :timezone, :string        
  end
  
  def self.down
    remove_column :profiles, :timezone
  end
end

