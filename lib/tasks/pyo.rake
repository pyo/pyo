namespace :pyo
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
      GroupCategory.create(:name => name)
    end
  end
end