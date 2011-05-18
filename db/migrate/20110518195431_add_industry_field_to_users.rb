class AddIndustryFieldToUsers < ActiveRecord::Migration
  def self.up
  	add_column :users, :industry, :string
  end

  def self.down
  	remove_column :users, :industry
  end
end
