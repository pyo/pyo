class ChangePayloadOnActivity < ActiveRecord::Migration
  def self.up
    remove_column :activities, :payload
    add_column :activities, :payload_type, :string
    add_column :activities, :payload_id, :integer
    add_index :activities, [:payload_type, :payload_id]
    
  end

  def self.down
    rename_column :activities, :payload_id, :payload
    remove_column :activities, :payload_type
  end
end
