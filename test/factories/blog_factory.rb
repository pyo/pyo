Factory.define :blog do |blog|
  blog.title 'MyString'
  blog.body 'MyText'
  blog.user_id '1'
end

Factory.sequence :blog do |n|
	
	Factory.create(:blog,{
		:title => "My Blog #{n}"
	})
	
end
