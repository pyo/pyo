class Profile < ActiveRecord::Base
  # vaildations
  validates_presence_of :first_name,  :message => "can't be blank"
  validates_presence_of :last_name,   :message => "can't be blank"
  validates_presence_of :username,    :message => "can't be blank"
  validates_presence_of :city,        :message => "can't be blank"
  validates_presence_of :state,       :message => "can't be blank"
  validates_presence_of :zip,         :message => "can't be blank"
  
  has_attached_file :avatar,
                    :styles => { 
                      :thumb => '60x60#', 
                      :medium => "600>",
                      :profile => "200>"
                    },
                    :whiny_thumbnails => true,
                    :path => ':rails_root/public/data/:class/:id/:style/:basename.:extension',
                    :url => '/data/:class/:id/:style/:basename.:extension',
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :path => ":attachment/:id/:style.:extension",
                    :bucket => "pyo-images-#{RAILS_ENV}"
  
  # assocs
  belongs_to :user
end
