require "#{File.dirname(__FILE__)}/../../vendor/plugins/moonshine/lib/moonshine.rb"
class ApplicationManifest < Moonshine::Manifest::Rails
  # The majority of your configuration should be in <tt>config/moonshine.yml</tt>
  # If necessary, you may provide extra configuration directly in this class 
  # using the configure method. The hash passed to the configure method is deep 
  # merged with what is in <tt>config/moonshine.yml</tt>. This could be used, 
  # for example, to store passwords and/or private keys outside of your SCM, or 
  # to query a web service for configuration data.
  #
  # In the example below, the value configuration[:custom][:random] can be used in 
  # your moonshine settings or templates.
  #
  # require 'net/http'
  # require 'json'
  # random = JSON::load(Net::HTTP.get(URI.parse('http://twitter.com/statuses/public_timeline.json'))).last['id']
  # configure({
  #   :custom => { :random => random  }
  # })

  # The default_stack recipe install Rails, Apache, Passenger, the database from 
  # database.yml, Postfix, Cron, logrotate and NTP. See lib/moonshine/manifest/rails.rb
  # for details. To customize, remove this recipe and specify the components you want.

  case deploy_stage
    when "production" then
      configure({
        :application => "putyourselfon.com",
        :deploy_to => "/home/admin/public_html/putyourselfon.com",
        :domain => "putyourselfon.com",
        :domain_aliases => [ "www.putyourselfon.com" ]
      })
    when "staging" then 
      configure({
        :application => "staging.putyourselfon.com",
        :deploy_to => "/home/admin/public_html/staging.putyourselfon.com",
        :domain => "staging.putyourselfon.com",        
        :domain_aliases => [ "174.129.227.77" ]
      })    
  end

  plugin :ds_tools
  recipe :ds_tools_apache

  configure(:ssh  => {
    :port  => "30306",
    :allow_users => ['admin']  
  })
  plugin :ssh
  recipe :ssh

  plugin :php
  recipe :php
  
  plugin :phpmyadmin
  recipe :phpmyadmin
  
  plugin :astrails_safe
  recipe :astrails_safe
  
  recipe :default_stack

  # Add your application's custom requirements here
  def application_packages
    # If you've already told Moonshine about a package required by a gem with
    # :apt_gems in <tt>moonshine.yml</tt> you do not need to include it here.
    # package 'some_native_package', :ensure => :installed
    
    # some_rake_task = "/usr/bin/rake -f #{configuration[:deploy_to]}/current/Rakefile custom:task RAILS_ENV=#{ENV['RAILS_ENV']}"
    # cron 'custom:task', :command => some_rake_task, :user => configuration[:user], :minute => 0, :hour => 0
    
    # %w( root rails ).each do |user|
    #   mailalias user, :recipient => 'you@domain.com'
    # end
    
    # farm_config = <<-CONFIG
    #   MOOCOWS = 3
    #   HORSIES = 10
    # CONFIG
    # file '/etc/farm.conf', :ensure => :present, :content => farm_config
    
    # Logs for Rails, MySQL, and Apache are rotated by default
    # logrotate '/var/log/some_service.log', :options => %w(weekly missingok compress), :postrotate => '/etc/init.d/some_service restart'
    
    # Only run the following on the 'testing' stage using capistrano-ext's multistage functionality.
    # on_stage 'testing' do
    #   file '/etc/motd', :ensure => :file, :content => "Welcome to the TEST server!"
    # end
  
    cron "#{deploy_stage}_daily_backup",
       :command => "astrails-safe #{configuration[:deploy_to]}/shared/config/astrails_safe_backup.conf",
       :user => "root",
       :minute => "0",
       :hour => "0"
    
  end
  # The following line includes the 'application_packages' recipe defined above
  recipe :application_packages
end