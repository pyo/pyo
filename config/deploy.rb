set :stages, %w(staging production testing)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

set :application, "PYO"
require 'capsize'

after :deploy    do
  run "/usr/bin/rake -f #{deploy_to}/current/Rakefile ts:index RAILS_ENV=#{rails_env}"
  run "/usr/bin/rake -f #{deploy_to}/current/Rakefile ts:rebuild RAILS_ENV=#{rails_env}"
end
