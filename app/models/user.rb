class User < ActiveRecord::Base
  include Clearance::App::Models::User
  has_one :profile, :dependent => :destroy
end