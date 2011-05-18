ActiveRecord::Schema.define :version => 0 do
  create_table :users, :force => true do |t|
    t.column :name, :string
  end
  
  create_table :groups, :force => true do |t|
     t.column :name, :string
   end
  
  create_table :memberships, :force => true do |t|
    t.string :parent_type
    t.integer :parent_id
    t.string :child_type
    t.integer :child_id
    t.string :state
    t.string :status
  end
  
end