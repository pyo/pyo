class SessionsController < ApplicationController
  # facebooker methods
  before_filter :set_facebook_session
  helper_method :facebook_session
  
  include Clearance::App::Controllers::SessionsController
end
