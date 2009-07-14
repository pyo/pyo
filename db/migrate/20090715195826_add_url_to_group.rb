class AddUrlToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :url, :string
  end

  def self.down
    remove_column :groups, :url
  end
end
