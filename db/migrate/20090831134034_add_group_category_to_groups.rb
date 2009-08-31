class AddGroupCategoryToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :group_category_id, :integer        
  end
  
  def self.down
    remove_column :groups, :group_category_id
  end
end

