class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.string :type
      t.string :title
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.integer :user_id
    
      t.timestamps
    end

		add_index :events, :type
		add_index :events, :title
		add_index :events, :start_date
		add_index :events, :end_date
		add_index :events, :user_id
  end

  def self.down
    drop_table :events
  end
end
