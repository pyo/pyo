server "174.129.23.221", :app, :web, :db, :primary => true
set :branch, "staging"

set :application, "staging.putyourselfon.com"
set :deploy_to, "/srv/putyourselfon_staging"
set :domain, "staging.putyourselfon.com"

set :rails_env, "staging"
set :keep_releases, 20  

namespace :deploy do
    
end
