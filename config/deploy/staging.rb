server "67.202.20.214", :app, :web, :db, :primary => true
set :rails_env, "staging"

set :branch, "master" unless exists?(:branch)