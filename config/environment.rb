# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  
  # Specify gems that this application depends on and have them installed with rake gems:install
  config.gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com'
  config.gem 'thoughtbot-paperclip',    :lib => 'paperclip', :source => 'http://gems.github.com'
  config.gem 'paperclip' # flags moonshine to install imagemagick
  config.gem 'thoughtbot-shoulda',      :lib => 'shoulda', :source => 'http://gems.github.com'
  config.gem 'giraffesoft-is_taggable', :lib => "is_taggable", :source => "http://gems.github.com"
  config.gem "thoughtbot-clearance",    :lib => 'clearance', :source => 'http://gems.github.com'
  config.gem 'right_aws'
  config.gem 'right_http_connection'
  config.gem 'andand'
  config.gem 'httparty'
  config.gem 'haml'
  config.gem 'capistrano'
  config.gem 'jnewland-capsize', :lib => false, :source => 'http://gems.github.com' # deployment tasks on ec2
	config.gem 'crack'

  # Activate observers that should always be running
  #config.active_record.observers = :covalence_notification_observer
  
  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

end


require 'tag_ext'
MAX_STARS = 5