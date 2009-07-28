Factory.define :video do |video|
  video.title 'MyString'
  video.panda_id 'MyString'
  video.filename 'MyString'
  video.width '480'
  video.height '360'
  video.user_id '1'
  video.description "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
end

Factory.sequence :video do |n|
	
	Factory.create(:video,{
		:title=>"Movie No. #{n}",
		:filename=>"movie_no_#{n}.mp4"
	})
	
end
