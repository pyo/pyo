class AddCountryToProfiles < ActiveRecord::Migration
  def self.up
    add_column :profiles, :country, :string        
  end
  
  def self.down
    remove_column :profiles, :country
  end
end

