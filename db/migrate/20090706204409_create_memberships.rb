class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table "memberships", :force => true do |t|
      t.string   "parent_type"
      t.integer  "parent_id"
      t.string   "child_type"
      t.integer  "child_id"
      t.string   "state"
      t.string   "status"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "role"
    end
    
    add_index :memberships, [:parent_id,:parent_type]
    add_index :memberships, [:child_id,:child_type]
    add_index :memberships, :state
    add_index :memberships, :status
    add_index :memberships, :role
    
  end

  def self.down
    drop_table :memberships
  end
end
