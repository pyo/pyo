Factory.define :tag do |tag|
  tag.name 'awesome'
	tag.kind 'tag'
end

Factory.sequence :tag do |n|
	
	Factory.create(:tag,{
		:name=>"tag tag #{n}"
	})
	
end
