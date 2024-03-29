# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
#config.action_controller.perform_caching             = false
config.gem "josevalim-rails-footnotes",  :lib => "rails-footnotes", :source => "http://gems.github.com"
# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# clearance
HOST = "localhost"

Paperclip.options[:image_magick_path] = '/opt/local/bin/'

ActionMailer::Base.smtp_settings = {
  :domain => "putyourselfon.com"
}

ActionController::Base.cache_store = :file_store, "tmp/cache"
config.action_controller.perform_caching = true

#im_dir = `which identify`
#im_dir = if im_dir.nil? or im_dir.empty?
#  '/opt/local/bin/'
#else
#  File.dirname(im_dir)
#end
#Paperclip.options[:image_magick_path] = im_dir
