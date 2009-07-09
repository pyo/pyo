require 'config/environment'

twitter = Twitter.new("twoism","")

puts twitter.timeline(:user)

