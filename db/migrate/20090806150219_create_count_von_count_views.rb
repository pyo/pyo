class CreateCountVonCountViews < ActiveRecord::Migration
  def self.up
    create_table :count_von_count_views do |t|
      t.string :model_type
      t.integer :model_id
      t.string :ip_addr
      t.timestamps
    end
    
    add_index :count_von_count_views, [:model_type, :model_id]
    add_index :count_von_count_views, :ip_addr
  end

  def self.down
    drop_table :count_von_count_views
  end
end