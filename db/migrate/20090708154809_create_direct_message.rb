class CreateDirectMessage < ActiveRecord::Migration
  def self.up
    create_table :direct_messages do |t|
      t.string :producer_type
      t.integer :producer_id
      t.string :consumer_type
      t.integer :consumer_id
      t.string :state, :default => 'new'
      t.string :message

      t.timestamps
      
      
    end
    add_index :direct_messages, [:producer_id,:producer_type]
    add_index :direct_messages, [:consumer_type,:consumer_id]
    add_index :direct_messages, :state
  end

  def self.down
    drop_table :direct_messages
  end
end
