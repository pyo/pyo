set :stages, %w(staging production)
set :default_stage, 'staging'
require 'capistrano/ext/multistage' rescue 'YOU NEED TO INSTALL THE capistrano-ext GEM'

after :deploy    do
  run "/usr/bin/rake -f #{deploy_to}/current/Rakefile ts:index RAILS_ENV=#{rails_env}"
  run "/usr/bin/rake -f #{deploy_to}/current/Rakefile ts:rebuild RAILS_ENV=#{rails_env}"
end
