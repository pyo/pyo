class AddPayloadToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :payload, :text
  end

  def self.down
    remove_column :activities, :payload
  end
end
