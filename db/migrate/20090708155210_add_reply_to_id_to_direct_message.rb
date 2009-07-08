class AddReplyToIdToDirectMessage < ActiveRecord::Migration
  def self.up
    add_column :direct_messages, :reply_to_id, :integer
    add_index  :direct_messages, :reply_to_id
  end

  def self.down
    remove_column :direct_messages, :reply_to_id
  end
end
