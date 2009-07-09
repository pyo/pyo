set :stages, %w(staging production testing)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "PYO"
require 'capsize'

set :port, ENV['PORT'] || "30306"