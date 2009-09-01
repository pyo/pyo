class RenameTypeToFlavorOnActivity < ActiveRecord::Migration
  def self.up
    rename_column :activities, :type, :flavor
  end
  
  def self.down
    rename_column :activities, :flavor, :type
  end
end

