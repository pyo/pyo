namespace :pyo do
  desc "Import group categories into website"
  task :group_categories => :environment do
    categories = %[Arts & Literature
    Business & Entrepreneurs
    Comedy & Humor
    Countries & Regions
    Cultures & Communities
    Entertainment & Celebrities
    Education & Schools
    Everyday Life
    Fashion & Style
    Film & Television
    Food & Drinks
    Fraternities & Sororities
    Health & Fitness
    Hobbies & Crafts
    Games/Gaming
    How-to & DIY
    Music
    News & Politics
    Nightlife & Clubs
    Outdoors & Nature
    Other
    Pets & Animals
    Philanthropy & Non Profits
    Places & Travel
    Products
    Science & Tech
    Sports & Recreation]
    
    categories.split("\n").each do |name|
      GroupCategory.create(:name => name.strip)
    end
  end

	desc "Populate with users and follow each other" 
	task :make_a_society => :environment do
		require 'faker'
		
		# puts "Purging all user data"
		# 
		# connection = ActiveRecord::Base.connection
		# %w{users profiles followings}.each do |table|
		# 	connection.execute("TRUNCATE #{table}");
		# end

		
		num_users = rand(250)
		puts "Creating #{num_users} Users"
		
		num_users.times do |i|
			first_name = Faker::Name.first_name
			last_name = Faker::Name.last_name
			user_name = Faker::Internet.user_name("#{first_name}.#{last_name}#{i}").gsub(/[^\w0-9]+/,["_",""].rand)
			user = User.create({
				:email=>"#{user_name}@staging.putyourselfon.com",
				:email_confirmed=>true,
				:password=>"testit!", 
				:name=>user_name,
				:first_run=>true,
				:super_user=>false,
				:talent_type=>["Musician","Filmmaker","Painter","Athelete","DJ","Comedian","Dancer","HipHip Artist","Bass Player","Drummer","Oragamist","Sheep Herder"].rand,
				:twitter_username=>"",
				:twitter_password=>"",
				:flickr_username=>"",
				:featured=>[true,false,false,false].rand,
				:tag_list=>Faker::Lorem.words(rand(10)+1)
			})
				
			user.profile = Profile.create({
				:first_name=>first_name,
				:last_name=>last_name,
				:username=>user_name,
				:address=>Faker::Address.street_address([true,false,false].rand),
				:city=>Faker::Address.city,
				:state=>Faker::Address.us_state_abbr,
				:zip=>Faker::Address.zip_code,
				:twitter=>"",
				:youtube=>"",
				:flickr=>"",
				:bio=>Faker::Lorem.paragraph(rand(5)),
				:country=>"US",
				:timezone=>"-5.0",
				:url=>"http://#{Faker::Internet.domain_name}"
			})	
			user.save
			raise user.errors.to_yaml unless user.valid?
			user.update_attribute(:email_confirmed,true)
		end
		
		puts "Creating relationships for users "

		User.all.each do |user|
			User.all(:conditions=>["id != ?", user.id], :limit=>rand(25)+5, :order=>"RAND()").each do |friend|
				Following.create(:parent => user, :child => friend) if Following.find_by_parent_id_and_child_id(user.id,friend.id).nil?
			end
		end
		
		puts "Your society is complete"
		
	end

end