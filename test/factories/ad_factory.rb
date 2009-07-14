Factory.define :ad do |booking|
  booking.title 'MyString'
  booking.description "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
  booking.user_id '1'
end

Factory.sequence :ad do |n|
	
	Factory.create(:ad,{
		:title=>"Event #{n}"
	})
	
end
