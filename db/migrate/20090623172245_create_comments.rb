class CreateComments < ActiveRecord::Migration
  def self.up
    create_table :comments do |t|
      t.string :producer_type
      t.integer :producer_id
      t.string :consumer_type
      t.integer :consumer_id
      t.string :state, :default => 'new'
      t.string :message

      t.timestamps
    end
    add_index :comments, [:producer_id,:producer_type]
    add_index :comments, [:consumer_type,:consumer_id]
    add_index :comments, :state
  end

  def self.down
    drop_table :comments
  end
end
