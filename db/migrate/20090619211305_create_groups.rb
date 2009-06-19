class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name
      t.text :description
      t.string :icon_file_name
      t.string :icon_content_type
      t.integer :icon_file_size

      t.timestamps
    end
    add_index :groups, :name
  end

  def self.down
    drop_table :groups
  end
end
