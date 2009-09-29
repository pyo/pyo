class ChangeDirectMessagesColumn < ActiveRecord::Migration
  def self.up
    change_column :direct_messages, :message, :text
  end

  def self.down
    change_column :direct_messages, :message, :string
  end
end
