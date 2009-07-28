# require 'config/environment'
# 
# twitter = Twitter.new("twoism","halcy0n")
# 
# twitter.timeline(:user,:query=>{:count=>8}).each do |t|
#   puts t["user"]["profile_image_url"]
# end
# 

require 'config/environment'

u = User.first
u.flickr_username = 'halogenandtoast'
u.save

puts u.flickr_id


u.flickr_username = 'branmurph'
u.save

puts u.flickr_id

# CHA CHA CHA CHANGES