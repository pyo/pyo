class AddIndexesAndUserToProfile < ActiveRecord::Migration
  def self.up
    add_index :profiles, :first_name
    add_index :profiles, :last_name
    add_index :profiles, :username
    add_index :profiles, :city
    add_index :profiles, :state
    add_index :profiles, :address
    add_index :profiles, :zip
    
    
    add_column :profiles, :user_id, :integer
    add_index  :profiles, :user_id
  end

  def self.down
    remove_column :profiles, :user_id
  end
end
