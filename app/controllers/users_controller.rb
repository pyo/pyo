class UsersController < ApplicationController
  # facebooker methods
  before_filter :set_facebook_session
  helper_method :facebook_session
  
  # clearance
  include Clearance::App::Controllers::UsersController
end