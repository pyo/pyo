Factory.define :user do |user|
  user.email "mawcus#{Time.now.to_i}@digitalscientists.com"
  user.password 'testit!'
  user.name 'marcus'
  user.first_run true
  user.super_user false
	user.talent_type "Fan"
	user.twitter_username "meanmarcus"
	user.twitter_password "testit!"
	user.flickr_username "meanmarcus"
	user.tag_list ["meanmarcus"]
end

Factory.sequence :user do |n|
	Factory.create(:user,{
		:email => "user_#{n}@ds.com",
		:name => "user_#{n}"
	})

end
