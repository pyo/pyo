#############################################################
#	Application
#############################################################

set :application, "PYO"
set :deploy_to, ""

#############################################################
#	Settings
#############################################################

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:port] = 22
set :use_sudo, false
set :scm_verbose, true
set :rails_env, "staging"
set :keep_releases, 20  

#############################################################
#	Servers
#############################################################

set :user, ""
set :domain, "208.52.138.243"
server domain, :app, :web
role :db, domain, :primary => true

#############################################################
#	Git
#############################################################

set :scm, :git
set :branch, "staging"
set :scm_user, 'digitalscientists'
set :scm_passphrase, "scooterpie5"
set :repository, "git@git.assembla.com:pyo.git"
set :deploy_via, :remote_cache
set :git, "/usr/local/bin/git"

#############################################################
#	Passenger
#############################################################

namespace :deploy do
  desc "Create the database yaml file"
  task :after_update_code do
    db_config = <<-EOF
    production:    
      adapter: mysql
      encoding: utf8
      username: root
      password: ideas8nited
      database: cmf_production
      host: 127.0.0.1
    EOF
    
    put db_config, "#{release_path}/config/database.yml"
    
    #########################################################
    # Uncomment the following to symlink an uploads directory.
    # Just change the paths to whatever you need.
    #########################################################

    
    desc "Creating Symlinks"
    task :before_symlink do
      dirs = %w{}.each do |dir|
        run "mkdir -p #{shared_path}/#{dir}"
        run "ln -s #{shared_path}/#{dir} #{release_path}/public/#{dir}"
      end
      run "mkdir -p #{shared_path}/index"
      run "ln -s #{shared_path}/index #{release_path}/index"
    end
  
  end
    
  # Restart passenger on deploy
  desc "Restarting mod_rails with restart.txt and rebuilding assets."
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path}; /opt/local/bin/git submodule init"
    run "cd #{current_path}; /opt/local/bin/git submodule update"
    run "touch #{current_path}/tmp/restart.txt"
    # run "cd #{deploy_to}/current; /usr/bin/rake asset:packager:build_all"
    deploy.web.enable
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
  
end
