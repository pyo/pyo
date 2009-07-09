module Php

  # Define options for this plugin via the <tt>configure</tt> method
  # in your application manifest:
  #
  #   configure(:php => {:foo => true})
  #
  # Then include the plugin and call the recipe(s) you need:
  #
  #  plugin :php
  #  recipe :php
  def php(options = {})
    # define the recipe
    # options specified with the configure method will be 
    # automatically available here in the options hash.
    #    options[:foo]   # => true
    
    package "libapache2-mod-fcgid", :ensure => :installed

    package "php5", :ensure => :installed, :require => package('libapache2-mod-fcgid')
    package "php5-cgi", :ensure => :installed, :require => package('libapache2-mod-fcgid')
    package "php5-cli", :ensure => :installed, :require => package('libapache2-mod-fcgid')
    package "php5-mysql", :ensure => :installed, :require => package('libapache2-mod-fcgid')
    package "php5-gd", :ensure => :installed, :require => package('libapache2-mod-fcgid')

    package "php5-curl", :ensure => :installed
    package "php5-dev", :ensure => :installed
    package "php5-imagick", :ensure => :installed
    package "php5-mcrypt", :ensure => :installed
    package "php5-memcache", :ensure => :installed
    package "php5-mhash", :ensure => :installed
    package "php5-pspell", :ensure => :installed
    package "php5-snmp", :ensure => :installed
    package "php5-sqlite", :ensure => :installed
    package "php5-xmlrpc", :ensure => :installed
    package "php5-xsl", :ensure => :installed

    a2enmod 'fcgid'
    
    file '/etc/php5/cgi/php.ini',
      :ensure => :present,
      :content => template(File.join(File.dirname(__FILE__), 'templates', 'php.ini.erb')),
      :notify => service("apache2"),
      :alias => "php_ini"

  end

end