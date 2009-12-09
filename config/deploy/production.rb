server "174.129.23.221", :app, :web, :db, :primary => true
set :branch, "master"

set :application, "putyourselfon.com"
set :deploy_to, "/srv/putyourselfon"
set :domain, "putyourselfon.com"

set :rails_env, "production"
set :keep_releases, 20  

namespace :deploy do
    
end
