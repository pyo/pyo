class CreateGroupCategories < ActiveRecord::Migration
  def self.up
    create_table :group_categories do |t|
      t.string :name
      t.integer :groups_count, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :group_categories
  end
end
