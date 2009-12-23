module Imagemagick

  # Define options for this plugin via the <tt>configure</tt> method
  # in your application manifest:
  #
  #   configure(:imagemagick => {:foo => true})
  #
  # Then include the plugin and call the recipe(s) you need:
  #
  #  plugin :imagemagick
  #  recipe :imagemagick
  def imagemagick(options = {})
    %w(
      imagemagick
      libmagick9-dev
    ).each do |p|
      package p, :ensure => :installed, :before => exec('rails_gems')
    end
  end
  
end