class AddSearchCountToTag < ActiveRecord::Migration
  def self.up
    add_column :tags, :search_count, :integer, :default=>0
		add_index :tags, :search_count
  end

  def self.down
    remove_column :tags, :search_count
  end
end
