class RenameFlavorToType < ActiveRecord::Migration
  def self.up
    rename_column :activities, :flavor, :type
  end
  
  def self.down
    rename_column :activities, :type, :flavor
  end
end

