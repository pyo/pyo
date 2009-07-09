class AddTalentTypeToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :talent_type, :string
    add_index  :users, :talent_type
  end

  def self.down
    remove_column :users, :talent_type
  end
end
