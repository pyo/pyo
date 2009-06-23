class CreateActivities < ActiveRecord::Migration
  def self.up
    create_table :activities do |t|
      t.string :producer_type
      t.integer :producer_id
      t.string :consumer_type
      t.integer :consumer_id
      t.string :state, :default => 'new'
      t.string :message
      t.string :flavor

      t.timestamps
    end
  end

  def self.down
    drop_table :activities
  end
end
