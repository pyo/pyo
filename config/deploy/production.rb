server "174.129.227.77", :app, :web, :db, :primary => true
set :branch, "master"

set :application, "putyourselfon.com"
set :deploy_to, "/home/admin/public_html/putyourselfon.com"
set :domain, "putyourselfon.com"

set :rails_env, "production"
set :keep_releases, 20  

namespace :deploy do
    
end