class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.string :first_name
      t.string :last_name
      t.string :username
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :twitter
      t.string :youtube
      t.string :flickr
      t.text :bio

      t.timestamps
    end
  end

  def self.down
    drop_table :profiles
  end
end
