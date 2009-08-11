class AddDescriptionToPhotos < ActiveRecord::Migration
  def self.up
    add_column :photos, :description, :text        
  end
  
  def self.down
    remove_column :photos, :description
  end
end

