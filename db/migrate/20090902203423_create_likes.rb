class CreateLikes < ActiveRecord::Migration
  def self.up
    create_table :likes do |t|
      t.integer :user_id
      t.string :media_type
      t.integer :media_id

      t.timestamps
    end
  end

  def self.down
    drop_table :likes
  end
end
