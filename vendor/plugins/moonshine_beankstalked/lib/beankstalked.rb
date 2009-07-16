module Beankstalked

  # Define options for this plugin via the <tt>configure</tt> method
  # in your application manifest:
  #
  #   configure(:beankstalked => {:foo => true})
  #
  # Then include the plugin and call the recipe(s) you need:
  #
  #  plugin :beankstalked
  #  recipe :beankstalked
  def beankstalked(options = {})
    # define the recipe
    # options specified with the configure method will be 
    # automatically available here in the options hash.
    #    options[:foo]   # => true

    @beanstalkd_install_script = 
%{mkdir /tmp/bean_src
cd /tmp/bean_src
curl -O http://monkey.org/~provos/libevent-1.4.11-stable.tar.gz
tar xzvf libevent-1.4.11-stable.tar.gz 
cd libevent-1.4.11-stable
./configure && make
sudo make install
cd ..
curl -O http://xph.us/dist/beanstalkd/beanstalkd-1.3.tar.gz
tar xzvf beanstalkd-1.3.tar.gz
cd beanstalkd-1.3
./configure && make
sudo mv beanstalkd /usr/local/bin/
}

  exec "install_beanstalkd",
    :command => @beanstalkd_install_script,
    :unless => ["which beanstalkd", "ls /usr/lib | libevent"]
  end
  
end