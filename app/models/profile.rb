class Profile < ActiveRecord::Base
  # vaildations
  validates_presence_of   :username, :message => "can't be blank"
  validates_uniqueness_of :username, :message => "has already been taken.  Please choose a different username.", :case_sensitive => false
  validates_format_of     :username, :with => /^[-a-z0-9_.+]+$/i, :message => "Usernames can only contain letters, numbers, underscores, periods, pluses and dashes"
  validates_length_of     :username, :maximum => 15

  has_attached_file :avatar,
                    :styles => { 
                      :thumb => '50x50#', 
                      :dashboard => '80x80#',
                      :medium => "600>",
                      :profile => "250x250#",
                      :home => "195>x122>"
                    },
                    :whiny_thumbnails => true,
                    :path => ':rails_root/public/data/:class/:id/:style/:basename.:extension',
                    :url => '/data/:class/:id/:style/:basename.:extension',
                    :storage => :s3,
                    :s3_credentials => "#{RAILS_ROOT}/config/s3.yml",
                    :path => ":attachment/:id/:style.:extension",
                    :bucket => "pyo-images-#{RAILS_ENV}",
                    :default_url => "/data/:class/:style.png"
  
  # assocs
  belongs_to :user

	def full_name
	  (first_name || '') + (last_name ? " #{last_name}" : '')
	end
	
	def full_name=(full_name)
	  self.first_name, *last_name = full_name.split(/ /)
	  self.last_name = last_name.join(' ')
  end
	
end
