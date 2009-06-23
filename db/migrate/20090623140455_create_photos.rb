class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos do |t|
      t.string :title
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.integer :user_id

      t.timestamps
    end
    
    add_index :photos, :title
    add_index :photos, :user_id
    
  end

  def self.down
    drop_table :photos
  end
end
