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
        :deploy_to => "/srv/putyourselfon",
        :domain => "putyourselfon.com",
        :domain_aliases => [ "www.putyourselfon.com" ]
      })
    when "staging" then 
      configure({
        :application => "staging.putyourselfon.com",
        :deploy_to => "/srv/putyourselfon_staging",
        :domain => "staging.putyourselfon.com",        
        :domain_aliases => [ "174.129.23.221" ]
      })    
  end

  plugin :ds_tools
  recipe :ds_tools_apache

  plugin :php
  recipe :php
  
  plugin :phpmyadmin
  recipe :phpmyadmin
  
  plugin :astrails_safe
  recipe :astrails_safe

  plugin :beankstalked
  recipe :beankstalked
  
  recipe :default_stack

  # Add your application's custom requirements here
  def application_packages
    
    rebuild_task = "/usr/bin/rake -f #{configuration[:deploy_to]}/current/Rakefile ts:index RAILS_ENV=#{ENV['RAILS_ENV']}"
    cron 'build_index', :command => rebuild_task, :user => configuration[:user], :minute => 0, :hour => "*"
  
    cron "#{deploy_stage}_daily_backup",
       :command => "astrails-safe #{configuration[:deploy_to]}/shared/config/astrails_safe_backup.conf",
       :user => "root",
       :minute => "0",
       :hour => "0"
    
  end
  # The following line includes the 'application_packages' recipe defined above
  recipe :application_packages
end
