# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090729212520) do

  create_table "activities", :force => true do |t|
    t.string   "producer_type"
    t.integer  "producer_id"
    t.string   "consumer_type"
    t.integer  "consumer_id"
    t.string   "state",         :default => "new"
    t.string   "message"
    t.string   "flavor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "payload_type"
    t.integer  "payload_id"
  end

  add_index "activities", ["payload_type", "payload_id"], :name => "index_activities_on_payload_type_and_payload_id"

  create_table "alerts", :force => true do |t|
    t.string   "producer_type"
    t.integer  "producer_id"
    t.string   "consumer_type"
    t.integer  "consumer_id"
    t.string   "state",         :default => "new"
    t.string   "flavor"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blogs", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "blogs", ["title"], :name => "index_blogs_on_title"
  add_index "blogs", ["user_id"], :name => "index_blogs_on_user_id"

  create_table "comments", :force => true do |t|
    t.string   "producer_type"
    t.integer  "producer_id"
    t.string   "consumer_type"
    t.integer  "consumer_id"
    t.string   "state",         :default => "new"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comments", ["consumer_type", "consumer_id"], :name => "index_comments_on_consumer_type_and_consumer_id"
  add_index "comments", ["producer_id", "producer_type"], :name => "index_comments_on_producer_id_and_producer_type"
  add_index "comments", ["state"], :name => "index_comments_on_state"

  create_table "direct_messages", :force => true do |t|
    t.string   "producer_type"
    t.integer  "producer_id"
    t.string   "consumer_type"
    t.integer  "consumer_id"
    t.string   "state",         :default => "new"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reply_to_id"
  end

  add_index "direct_messages", ["consumer_type", "consumer_id"], :name => "index_direct_messages_on_consumer_type_and_consumer_id"
  add_index "direct_messages", ["producer_id", "producer_type"], :name => "index_direct_messages_on_producer_id_and_producer_type"
  add_index "direct_messages", ["reply_to_id"], :name => "index_direct_messages_on_reply_to_id"
  add_index "direct_messages", ["state"], :name => "index_direct_messages_on_state"

  create_table "events", :force => true do |t|
    t.string   "type"
    t.string   "title"
    t.text     "description"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "group_id"
  end

  add_index "events", ["end_date"], :name => "index_events_on_end_date"
  add_index "events", ["group_id"], :name => "index_events_on_group_id"
  add_index "events", ["start_date"], :name => "index_events_on_start_date"
  add_index "events", ["title"], :name => "index_events_on_title"
  add_index "events", ["type"], :name => "index_events_on_type"
  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "followings", :force => true do |t|
    t.string   "parent_type"
    t.integer  "parent_id"
    t.string   "child_type"
    t.integer  "child_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "icon_file_name"
    t.string   "icon_content_type"
    t.integer  "icon_file_size"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "approved",          :default => false
    t.string   "url"
  end

  add_index "groups", ["approved"], :name => "index_groups_on_approved"
  add_index "groups", ["name"], :name => "index_groups_on_name"

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

  add_index "memberships", ["child_id", "child_type"], :name => "index_memberships_on_child_id_and_child_type"
  add_index "memberships", ["parent_id", "parent_type"], :name => "index_memberships_on_parent_id_and_parent_type"
  add_index "memberships", ["role"], :name => "index_memberships_on_role"
  add_index "memberships", ["state"], :name => "index_memberships_on_state"
  add_index "memberships", ["status"], :name => "index_memberships_on_status"

  create_table "photos", :force => true do |t|
    t.string   "title"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "photos", ["title"], :name => "index_photos_on_title"
  add_index "photos", ["user_id"], :name => "index_photos_on_user_id"

  create_table "profiles", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "username"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "twitter"
    t.string   "youtube"
    t.string   "flickr"
    t.text     "bio"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
  end

  add_index "profiles", ["address"], :name => "index_profiles_on_address"
  add_index "profiles", ["city"], :name => "index_profiles_on_city"
  add_index "profiles", ["first_name"], :name => "index_profiles_on_first_name"
  add_index "profiles", ["last_name"], :name => "index_profiles_on_last_name"
  add_index "profiles", ["state"], :name => "index_profiles_on_state"
  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"
  add_index "profiles", ["username"], :name => "index_profiles_on_username"
  add_index "profiles", ["zip"], :name => "index_profiles_on_zip"

  create_table "ratings", :force => true do |t|
    t.integer  "user_id"
    t.integer  "score"
    t.integer  "rateable_id"
    t.string   "rateable_type", :limit => 32
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["category"], :name => "index_ratings_on_category"
  add_index "ratings", ["rateable_id", "rateable_type"], :name => "index_ratings_on_rateable_id_and_rateable_type"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "taggings", :force => true do |t|
    t.integer "tag_id"
    t.string  "taggable_type", :default => ""
    t.integer "taggable_id"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string  "name",         :default => ""
    t.string  "kind",         :default => ""
    t.integer "search_count", :default => 0
  end

  add_index "tags", ["name", "kind"], :name => "index_tags_on_name_and_kind"
  add_index "tags", ["search_count"], :name => "index_tags_on_search_count"

  create_table "tracks", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "user_id"
    t.string   "mp3_file_name"
    t.integer  "mp3_file_size"
    t.string   "mp3_content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tracks", ["name"], :name => "index_tracks_on_name"
  add_index "tracks", ["user_id"], :name => "index_tracks_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "encrypted_password", :limit => 128
    t.string   "salt",               :limit => 128
    t.string   "token",              :limit => 128
    t.datetime "token_expires_at"
    t.boolean  "email_confirmed",                   :default => false, :null => false
    t.string   "name"
    t.boolean  "first_run",                         :default => true
    t.boolean  "super_user",                        :default => false
    t.string   "talent_type"
    t.string   "twitter_username"
    t.string   "twitter_password"
    t.string   "flickr_username"
    t.string   "flickr_id"
    t.boolean  "admin",                             :default => false
    t.boolean  "featured",                          :default => false
  end

  add_index "users", ["admin"], :name => "index_users_on_admin"
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["featured"], :name => "index_users_on_featured"
  add_index "users", ["first_run"], :name => "index_users_on_first_run"
  add_index "users", ["id", "token"], :name => "index_users_on_id_and_token"
  add_index "users", ["super_user"], :name => "index_users_on_super_user"
  add_index "users", ["talent_type"], :name => "index_users_on_talent_type"
  add_index "users", ["token"], :name => "index_users_on_token"

  create_table "videos", :force => true do |t|
    t.string   "title"
    t.string   "panda_id"
    t.string   "filename"
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.text     "description"
  end

end
