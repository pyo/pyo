class SessionsController < ApplicationController  
  include Clearance::App::Controllers::SessionsController
  
  private
  def url_after_create
    dashboard_path
  end
end
