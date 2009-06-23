class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.string :producer_type
      t.integer :producer_id
      t.string :consumer_type
      t.integer :consumer_id
      t.string :state, :default => 'new'
      t.string :flavor
      t.string :message

      t.timestamps
    end
  end

  def self.down
    drop_table :alerts
  end
end
