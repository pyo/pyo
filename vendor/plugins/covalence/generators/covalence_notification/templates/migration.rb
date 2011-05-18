class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table :<%= table_name %> do |t|
      t.string   "consumer_type"
      t.integer  "consumer_id"
      t.string   "producer_type"
      t.integer  "producer_id"
      t.string   "state", :default => 'new'
      t.text     "message"
<% for attribute in attributes -%>
      t.<%= attribute.type %> :<%= attribute.name %>
<% end -%>
<% unless options[:skip_timestamps] %>
      t.timestamps
<% end -%>
    end
    
    add_index :<%= table_name %>, [:producer_id, :producer_type]
    add_index :<%= table_name %>, [:consumer_id, :consumer_type]
    add_index :<%= table_name %>, :state
  end

  def self.down
    drop_table :<%= table_name %>
  end
end
