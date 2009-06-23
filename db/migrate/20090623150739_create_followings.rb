class CreateFollowings < ActiveRecord::Migration
  def self.up
    create_table :followings do |t|
      t.string :parent_type
      t.integer :parent_id
      t.string :child_type
      t.integer :child_id

      t.timestamps
    end
  end

  def self.down
    drop_table :followings
  end
end
