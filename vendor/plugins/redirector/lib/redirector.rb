module Redirector
  module Routes
    def redirect(path, *args)
      connect path, :controller => "redirection", :action => "redirect", :conditions => { :method => :get }, :args => args
    end
  end
end

if defined?(ActionController)
  ActionController::Routing::RouteSet::Mapper.send :include, Redirector::Routes
end