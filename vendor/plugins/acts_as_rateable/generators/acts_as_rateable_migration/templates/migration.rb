class ActsAsRateableMigration < ActiveRecord::Migration
  def self.up
    
    create_table :ratings do |t|
    	t.column :user_id, :integer
      t.column :score, :integer
      t.column :rateable_id, :integer
      t.column :rateable_type, :string, :limit => 32
      t.column :category, :string, :null => true, :default => nil
      t.timestamps
    end
    
    add_index :ratings, [:rateable_id, :rateable_type]
    add_index :ratings, :category
  end
  
  def self.down
    drop_table :ratings
  end
end