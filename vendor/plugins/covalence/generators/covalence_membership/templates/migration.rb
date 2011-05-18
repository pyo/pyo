class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %> do |t|
      t.string :parent_type
      t.integer :parent_id
      t.string :child_type
      t.integer :child_id
      t.string :state
      t.string :status
<% for attribute in attributes -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>
<% unless options[:skip_timestamps] %>
      t.timestamps
<% end -%>
    end
    
    add_index :<%= table_name %>, [:parent_id, :parent_type]
    add_index :<%= table_name %>, [:child_id, :child_type]
    add_index :<%= table_name %>, :state
    add_index :<%= table_name %>, :status
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
