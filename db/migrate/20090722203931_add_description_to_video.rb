class AddDescriptionToVideo < ActiveRecord::Migration
  def self.up
    add_column :videos, :description, :text
  end

  def self.down
    remove_column :videos, :description
  end
end
