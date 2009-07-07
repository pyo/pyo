set :application, "PYO"
require 'capsize'

set :domain, "174.129.227.77"
server domain, :app, :web
role :db, domain, :primary => true

set :port, ENV['PORT'] || "30306"

set :branch, "server_setup"
set :scm_user, 'digitalscientists'
set :scm_passphrase, "scooterpie5"

# set :stages, %w(staging production testing)
# set :default_stage, "staging"
# require 'capistrano/ext/multistage'