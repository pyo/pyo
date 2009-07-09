module Phpmyadmin

  # Define options for this plugin via the <tt>configure</tt> method
  # in your application manifest:
  #
  #   configure(:phpmyadmin => {:foo => true})
  #
  # Then include the plugin and call the recipe(s) you need:
  #
  #  plugin :phpmyadmin
  #  recipe :phpmyadmin
  def phpmyadmin(options = {})
    # define the recipe
    # options specified with the configure method will be 
    # automatically available here in the options hash.
    #    options[:foo]   # => true
    
    package "phpmyadmin", :ensure => :installed

    file '/etc/apache2/conf.d/phpmyadmin.conf',
      :ensure => :present,
      :content => template(File.join(File.dirname(__FILE__), 'templates', 'phpmyadmin.conf.erb')),
      :notify => service("apache2"),
      :alias => "phpmyadmin"
    
  end
  
end