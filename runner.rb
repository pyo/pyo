# require 'config/environment'
# 
# twitter = Twitter.new("twoism","halcy0n")
# 
# twitter.timeline(:user,:query=>{:count=>8}).each do |t|
#   puts t["user"]["profile_image_url"]
# end
# 

require 'config/environment'

cols = Profile.columns.map(&:name)
puts cols.collect {|c| ":#{c}=>\"\"," }