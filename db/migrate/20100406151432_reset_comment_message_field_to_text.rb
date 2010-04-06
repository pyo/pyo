class ResetCommentMessageFieldToText < ActiveRecord::Migration
  def self.up
    change_column :comments, :message, :text
  end

  def self.down
    change_column :comments, :message, :string
  end
end
