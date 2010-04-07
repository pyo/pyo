class ChangeMessageFieldOnActivitiesToText < ActiveRecord::Migration
  def self.up
    change_column :activities, :message, :text
  end

  def self.down
    change_column :activities, :message, :string
  end
end
