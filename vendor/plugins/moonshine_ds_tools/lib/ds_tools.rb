module DsTools

  # Define options for this plugin via the <tt>configure</tt> method
  # in your application manifest:
  #
  #   configure(:ds_tools => {:foo => true})
  #
  # Then include the plugin and call the recipe(s) you need:
  #
  #  plugin :ds_tools
  #  recipe :ds_tools
  def ds_tools(options = {})
    # define the recipe
    # options specified with the configure method will be 
    # automatically available here in the options hash.
    #    options[:foo]   # => true
  end

  def ds_tools_apache(options = {})
    # Build httpd.conf file
    file '/etc/apache2/httpd.conf',
      :ensure => :present,
      :content => template(File.join(File.dirname(__FILE__), 'templates', 'httpd.conf.erb')),
      :notify => service("apache2"),
      :alias => "httpd_conf"
  end
  
end