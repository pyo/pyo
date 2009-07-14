Factory.define :group do |group|
  group.name 'MyString'
  group.description 'MyText'
end

Factory.sequence :group do |n|
	Factory.create(:group, {
		:name => "My String #{n}"
	})
end