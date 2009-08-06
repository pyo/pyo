Factory.define :profile do |profile|
  profile.first_name 'Carlyle'
  profile.last_name 'Hunderbinks'
  profile.username 'hunderlyle'
  profile.address '1212 North by Northwest'
  profile.city 'Atlanta'
  profile.state 'GA'
  profile.zip '30306'
  profile.twitter 'abcdefg'
  profile.youtube 'abcdefg'
  profile.flickr 'abcdefg'
  profile.bio 'Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.'
end

Factory.sequence :profile do |n|
	
	Factory.create(:profile, {
		:last_name => "Hunderbinks #{n}"
	})
	
end