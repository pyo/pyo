require 'covalence/notifications'
require 'covalence/groups'

module Covalence
  class << self
    def enable
      enable_actionpack
    end
    
    def enable_actionpack
      require 'covalence/view_helpers'
      ActionView::Base.send :include, ViewHelpers
    end
  end
end

if defined?(Rails) and defined?(ActiveRecord) and defined?(ActionController)
  Covalence.enable
end