class CreateTracks < ActiveRecord::Migration
  def self.up
    create_table :tracks do |t|
      t.string :name
      t.text :description
      t.integer :user_id
      t.string :mp3_file_name
      t.integer :mp3_file_size
      t.string :mp3_content_type

      t.timestamps
    end
    add_index :tracks, :name
    add_index :tracks, :user_id
  end

  def self.down
    drop_table :tracks
  end
end
